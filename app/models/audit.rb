require 'ap'
class Audit < ActiveRecord::Base
  serialize :election_data_hash # TODO: find maximum size for serialize
  attr_accessible :display_name, :election_data_hash, :district_set, :district_set_id, :content_type
  
  has_many :alerts
  belongs_to :district_set # TODO change to "Jurisdiction" when we do that.
  
  def auditing_jurisdiction?
    content_type.eql? "jurisdiction_info"
  end
  
  def auditing_election?
    content_type.eql? "election_info"
  end
  
  def auditing_candidate?
    content_type.eql? "candidate_info"
  end
  #
  # Audits election_data_hash (without touching it), producing more @alerts
  # 
  def audit
    @audit_in_progress = true
    raise ArgumentError, "Audit.audit: invalid content_type: #{content_type}" unless auditing_jurisdiction? || auditing_candidate? || auditing_election?
    
    # Now do each kind of sanity check, depending on type of input info we are auditing
    if auditing_jurisdiction?
      audit_sanity_check_body
      audit_sanity_check "precincts"
      audit_sanity_check "splits"
      audit_sanity_check "districts"
      audit_precincts
      audit_districts 
      audit_precinct_splits      
    elsif auditing_election?
      audit_sanity_check_body
      audit_sanity_check "elections"
      audit_sanity_check "contests"
      audit_elections
      audit_contests
    elsif auditing_candidate?
      audit_sanity_check_body
      audit_sanity_check "candidates"
      audit_candidates 
    end
    @audit_in_progress = false
    @audited = true
  end
  
  # Various basic sanity checks
  def audit_sanity_check_body
    unless election_data_hash.has_key?("body")
      raise ArgumentError, "Invalid format. No Body tag"
    end
  end
  
  def audit_sanity_check section
    unless election_data_hash.has_key?("body") && election_data_hash["body"].has_key?(section)
      raise ArgumentError, "Invalid format. No #{section} section."
    end
    unless election_data_hash["body"][section].reduce(true) { |memo, sect| sect.has_key?("ident") ? memo : false }
      raise ArgumentError, "Invalid format. All #{section} elements require an ident"
    end
  end
  
  def audit_jurisdictions
    # TODO: For each jurisdiction in election_data_hash["ballot_info"]["jurisdictions"], store ident
    # TODO: For each jurisdiction in EM DistrictSets.all.each { |district_set| # store ident }
  end
  
  def audit_precincts
    # TODO: For each precinct in election_data_hash["ballot_info"]["precincts"], store ident with display_name
    # After district audit, look for unattached precincts
  end
  
  def audit_precinct_splits
    election_data_hash["body"]["splits"].each_index {
      |index|
      audit_precinct_split index 
    } if election_data_hash["body"].has_key? "splits"
  end
  
  def audit_precinct_split split_index
    split = election_data_hash["body"]["splits"][split_index]
    if !input_has?(election_data_hash["body"]["district_sets"], "ident", split["district_set_ident"])
      logger.info "Alert: Invalid District #{election_data_hash["body"]["district_sets"].inspect}"
      alerts << Alert.new(:message => "Invalid DistrictSet \'#{split["district_set_ident"]}\' mentioned in Precinct Split \'#{split["ident"]}\'. What would you like to do? ", 
                          :alert_type => "invalid_ds_in_ps", 
                          :options => {"skip" => "Skip this split", 
                                       "abort" => "Abort import"}, 
                          :default_option => "abort")
      
    end
    if !input_has?(election_data_hash["body"]["precincts"], "ident", split["precinct_ident"])
      alerts << Alert.new(:message => "Invalid Precinct mentioned in Precinct Split:" + split["precinct_ident"]+ ". What would you like to do? ", 
                          :alert_type => "invalid_p_in_ps",
                          :options => {"skip" => "Skip this split", 
                                       "abort" => "Abort import"}, 
                          :default_option => "abort")
    end
  end
  
  # Run audit_contest on all contests in the input EDH
  def audit_contests
    election_data_hash["body"]["contests"].each_index do
      |contest_index|
      audit_contest contest_index
    end
  end
  
  # See if a particular Contest in the EDH looks reasonble:
  #  Example:
  #  election_ident: "14"
  #  ident: "500144"
  #  display_name: Member Board of Supervisors
  #  district_ident: "501233"
  #<tt>index:<tt>Contest index in election_data_hash["body"]["contests"]
  def audit_contest index 
    contest = election_data_hash["body"]["contests"][index]
    dist_ident = contest["district_ident"]
    cont_disp_name = contest["display_name"]
    if District.find_by_ident(dist_ident).nil?
      alerts << Alert.new(:message => "Unknown District: \'#{dist_ident}\' in Contest: \'#{cont_disp_name}\'",
                          :alert_type => "contest_invalid_district_ident",
                          :objects => index,
                          :options => {"skip" => "Skip this contest",
                                       "abort" => "Abort this import"},
                          :default_option => "skip")
    end
  end
  
  # audit all districts in the input EDH
  def audit_districts
    election_data_hash["body"]["districts"].each_index do
      |dist_index|
      audit_district_jurisdiction dist_index if !auditing_jurisdiction?
    end
  end
  
  # Check a particular District to make sure the Jurisdiction is valid.
  # Note that when auditing for jurisdiction import, this check is not needed, because import
  # target pre-specified.
  def audit_district_jurisdiction dist_index
    return if content_type == :jurisdiction
    district = election_data_hash["body"]["districts"][dist_index]
    if district && !district["jurisdiction_ident"]
      alerts << Alert.new(:message => "No Jurisdiction specified for district \'#{district["display_name"]}\'. What would you like to do? ", 
                          :alert_type => "no_jurisdiction", :objects => dist_index, 
                          :options => {"use_current" => "Use current #{district_set.display_name}", 
                                       "import" => "Import without a Jurisdiction", 
                                       "abort" => "Abort import"}, 
                          :default_option => "use_current")
    end
  end

# Audit all candidates in the input EDH  
  def audit_candidates
    election_data_hash["body"]["candidates"].each_index do
      |cand_index|
      audit_candidate cand_index
    end
  end
  
# Check whether a particular candidate in the EDH looks reasonable. For example:
#  - party_display_name: Independent
#    ident: "500586"
#    contest_ident: "500103"
#    display_name: Deborah D. "Deb" Wahlstrom
# <tt>cand_id:</tt>Index of this candidate in election_data_hash["body"]["candidates"]
  def audit_candidate cand_id
    candidate = election_data_hash["body"]["candidates"][cand_id]
    contest_ident = candidate["contest_ident"]
    if Contest.find_by_ident(contest_ident).nil?
      alerts << Alert.new(:message => "Unknown Contest \'#{contest_ident}\' for Candidate \'#{candidate["display_name"]}\'",
                          :alert_type => "candidate_invalid_contest_ident",
                          :objects => cand_id,
                          :options => {"skip" => "Skip this contest",
                                       "abort" => "Abort this import"},
                          :default_option => "skip")
    end
  end
  

# Audit all the Elections in the input EDH
  def audit_elections
    election_data_hash["body"]["elections"].each_index { |e_index| audit_election e_index }
  end
    
# Check whether a particular Election in the EDH looks reasonbable.
# <tt>e_index:</tt>Index of this Election in election_data_hash["body"]["elections"]
  def audit_election e_index
    elec = election_data_hash["body"]["elections"][e_index]
    if !elec.has_key? "display_name"
      alerts << Alert.new(:message => "Unnamed Election \'#{elec["ident"]}\'. ",
                          :alert_type => "unnamed_election",
                          :objects => e_index,
                          :options => {"skip" => "Skip this election",
                                       "abort" => "Abort this import",
                                       "default" => "Give election a default name"},
                          :default_option => "default")
    end
  end
    
  # Processes all the alerts. Those that are handled are deleted from the Alert list. The Audit will be 
  # run again until all Alerts have been handled.  
  def apply_alerts
    alerts.each { |alert| process_alert alert }
  end
  
  def process_alert alert
    case [alert.alert_type, alert.choice]
    when ["no_jurisdiction", "use_current"]
      # Make sure it has an ident
      district_set.before_validation
      election_data_hash["body"]["districts"][alert.objects.to_i]["jurisdiction_ident"] = district_set.ident
      Alert.delete(alert)
    when ["no_jurisdiction", "abort"]
      raise "Import aborted"
    when ["invalid_p_in_ps", "abort"]
      raise "Import aborted"
    when ["invalid_ds_in_ps", "abort"]
      raise "Import aborted"
    when ["contest_invalid_district_ident", "abort"]
      raise "Import aborted"
    when ["contest_invalid_district_ident", "skip"]
      election_data_hash["body"]["contests"].slice!(alert.objects.to_i)
      Alert.delete(alert)
    when ["candidate_invalid_contest_ident", "abort"]
      raise "Import aborted"
    when ["candidate_invalid_contest_ident", "skip"]
      election_data_hash["body"]["candidates"].slice!(alert.objects.to_i)
      Alert.delete(alert)
    when ["unnamed_election", "abort"]
      raise "Import aborted"
    when ["unnamed_election", "default"]
      election_data_hash["body"]["elections"][alert.objects.to_i]["display_name"] = "Election default-name-from-import"
      Alert.delete(alert)
    when ["unnamed_election", "skip"]
      election_data_hash["body"]["elections"].slice!(alert.objects.to_i)
      Alert.delete(alert)
    else
      raise ArgumentError, "Invalid code in Audit#process_alert"
    end
    self.save!
  end
  
  def ready_for_import?
    return ((alerts.count == 0) && !@audit_in_progress && @audited)
  end
  
  # Search through target (an array of hashes), 
  # for an element who has key equal to value
  def input_has? target, key, value
    target.each { |item| (return true if item[key].eql? value) }
    false
  end
  
  
end
