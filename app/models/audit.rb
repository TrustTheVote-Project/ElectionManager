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
      audit_precincts         # Collect IDs (so we know which ones are valid for districts)
      audit_districts 
      audit_precinct_splits      
    elsif auditing_election?
      audit_sanity_check_body
      audit_sanity_check "elections"
      audit_sanity_check "contests"
      audit_election
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
  
  def audit_candidates
# TODO: Audit Candidates    
  end 

  def audit_election
# TODO Audit Election
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
            alerts << Alert.new(:message => "Invalid DistrictSet mentioned in Precinct Split. What would you like to do? ", 
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
  
  def audit_contests
# TODO: Audit Contests    
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
  # target pre-specified.s
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
  
  # Applies transforms to @hash based on alerts
  def apply_alerts
    alerts.each{ |alert|
      if alert.alert_type == "no_jurisdiction" && alert.choice == "use_current"
        # Make sure it has an ident
        district_set.before_validation
        election_data_hash["body"]["districts"][alert.objects.to_i]["jurisdiction_ident"] = district_set.ident
        alerts.delete(alert)
      elsif alert.alert_type == "no_jurisdiction" && alert.choice == "abort"
        raise "Import aborted"
      elsif alert.alert_type == "invalid_p_in_ps" && alert.choice == "abort"
        raise "Import aborted"
      elsif alert.alert_type == "invalid_ds_in_ps" && alert.choice == "abort"
        raise "Import aborted"
      end        
    }  
    self.save!
  end

  def ready_for_import?
    return ((alerts.size == 0) && !@audit_in_progress && @audited)
  end
  
  # Search through target (an array of hashes), 
  # for an element who has key equal to value
  def input_has? target, key, value
    target.each { |item| (return true if item[key].eql? value) }
    false
  end
 

end
