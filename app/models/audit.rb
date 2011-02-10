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
      audit_sanity_check ["precincts", "splits", "districts", "district_sets"]
      audit_precincts
      audit_districts 
      audit_precinct_splits
      audit_district_sets
    elsif auditing_election?
      audit_sanity_check_body
      audit_sanity_check ["elections", "contests", "questions"]
      audit_elections
      audit_contests
      audit_questions
    elsif auditing_candidate?
      audit_sanity_check_body
      audit_sanity_check ["candidates", "questions"]
      audit_candidates
      audit_questions
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
  
# for each section in target-sections: if it is present, each sub-element must have an ident
# for each section found in the body, it better be one of the target-sections
  def audit_sanity_check target_sections
    target_sections.each do |target_sect|
      edh_sect = election_data_hash["body"][target_sect]
      if !edh_sect.nil?
        edh_sect.each_index do |element_index|
          if election_data_hash["body"][target_sect][element_index]["ident"].nil?
            alerts << Alert.new(:message => "An item in the #{target_sect} does not have a required ident" + ". What would you like to do? ", 
                                :alert_type => "missing_ident",
                                :options => {"skip" => "Skip this item",
                                             "generate" => "Generate one on the fly",
                                             "abort" => "Abort import"},
                                :objects => [target_sect, element_index],
                                :default_option => "generate")
          end
        end
      end
    end
    election_data_hash["body"].each_key do |input_sect|
      raise ArgumentError, "Invalid format. Unexpected #{input_sect} section encountered in import file" if !target_sections.member? input_sect
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
  
  def audit_district_sets
    
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
    election_data_hash["body"]["contests"].each_index do |contest_index|
      audit_contest contest_index
    end if election_data_hash["body"].has_key? "contests"
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

  # Run audit_question on all questions in the EDH
  def audit_questions
    election_data_hash["body"]["questions"].each_index do |question_index|
      audit_question question_index
    end if election_data_hash["body"].has_key? "questions"
  end
  
# See if a particular Question looks reasonable
# Example:
#    election_ident: "14"
#    ident: quest-e14-q1
#    display_name: Question 1
#    question: Shall Section 6 of Article X o
#    district_ident: 501630
  def audit_question quest_index
    quest = election_data_hash["body"]["questions"][quest_index]
    elect_ident = quest["election_ident"]
    if elect_ident.nil?
      alerts << Alert.new(:message => "No Election specified for question \'#{quest["display_name"]}\'. What would you like to do? ",
                          :alert_type => "no_elect_in_quest",
                          :objects => quest_index,
                          :options => {"skip" => "Skip question",
                                       "abort" => "Abort import"},
                          :default_option => "skip")
    elsif Election.find_by_ident(elect_ident).nil?
      alerts << Alert.new(:message => "Invalid Election (#{elect_ident}) specified for question \'#{quest["display_name"]}\'. What would you like to do? ",
                          :alert_type => "no_elect_in_quest",
                          :objects => quest_index,
                          :options => {"skip" => "Skip question",
                                       "abort" => "Abort import"},
                          :default_option => "skip")                          
    elsif quest["district_ident"].nil? && !quest["district_name"].nil?
      dist_name = quest["district_name"]
      guessed_dist = District.display_name_like(dist_name).first
      if !guessed_dist.nil?
        guessed_dist_name = guessed_dist.display_name
        guessed_dist_ident = guessed_dist.ident
      end  
      alerts << Alert.new(:message => "Looks like \'#{quest["display_name"]}\' should be associated with #{guessed_dist_name}. What would you like to do? ",
                          :alert_type => "no_district_ident_in_quest",
                          :objects => [quest_index, guessed_dist_ident],
                          :options => {"skip" => "Skip question",
                                       "repair" => "I agree, please update the question accordingly.",
                                       "abort" => "Abort import"},
                          :default_option => "repair")
    end
  end
  
  # audit all districts in the input EDH
  def audit_districts
    election_data_hash["body"]["districts"].each_index do
      |dist_index|
      audit_district_jurisdiction dist_index if !auditing_jurisdiction?
    end if election_data_hash["body"].has_key? "districts"
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
    end if election_data_hash["body"].has_key? "candidates"
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
    election_data_hash["body"]["elections"].each_index do |e_index| 
      audit_election e_index 
    end if election_data_hash["body"].has_key? "elections"
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
      alert.destroy
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
      alert.destroy
    when ["candidate_invalid_contest_ident", "abort"]
      raise "Import aborted"
    when ["candidate_invalid_contest_ident", "skip"]
      election_data_hash["body"]["candidates"].slice!(alert.objects.to_i)
      alert.destroy
    when ["unnamed_election", "abort"]
      raise "Import aborted"
    when ["unnamed_election", "default"]
      election_data_hash["body"]["elections"][alert.objects.to_i]["display_name"] = "Election default-name-from-import"
      alert.destroy
    when ["unnamed_election", "skip"]
      election_data_hash["body"]["elections"].slice!(alert.objects.to_i)
      alert.destroy
    when ["no_elect_in_quest", "abort"]
      raise "Import aborted"
    when ["no_elect_in_quest", "skip"]
      election_data_hash["body"]["questions"].slice!(alert.objects.to_i)
      alert.destroy
    when ["no_district_type_in_quest","skip"]
      election_data_hash["body"]["questions"].slice!(alert.objects.to_i)
      alert.destroy
    when ["no_district_ident_in_quest","repair"]
      question_number, district_ident = alert.objects
      election_data_hash["body"]["questions"][question_number]["district_ident"] = district_ident
      alert.destroy
    when ["no_district_type_in_quest","abort"]
      raise "Import aborted"
    when ["missing_ident", "skip"]
      election_data_hash["body"][alert.objects[0]].slice!(alert.objects[1].to_i)
      alert.destroy
    when ["missing_ident", "abort"]
      raise "Import aborted"
    when ["missing_ident", "generate"]
      election_data_hash["body"][alert.objects[0]][alert.objects[1].to_i]["ident"] = alert.objects[0].upcase + "-#{ActiveSupport::SecureRandom.hex}"
      alert.destroy
    else
      raise ArgumentError, "Invalid code in Audit#process_alert #{alert.alert_type}, #{alert.choice}"
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
