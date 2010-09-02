require 'ap'
class Audit < ActiveRecord::Base
  serialize :election_data_hash # TODO: find maximum size for serialize
  attr_accessible :display_name, :election_data_hash, :district_set, :district_set_id
  
  has_many :alerts
  
  belongs_to :district_set

  # Audits election_data_hash (without touching it), producing more @alerts
  # type -> :jurisdiction if this will be imported at Jurisdiction level
  #      -> :global if this will be imported at the top levels
  
  def audit audit_type=:global
    @audit_in_progress = true
    @audit_type = audit_type

# Now do each kind of sanity check    
    audit_sanity_check      # See if the file looks anything like what we want
    audit_jurisdictions     # Collect IDs of new jurisdictions and EM-imported jurisdictions
    audit_precincts         # Collect IDs (so we know which ones are valid for districts)
    audit_districts 
    audit_candidates
    audit_contests
    audit_precinct_splits

    @audit_in_progress = false
    @audited = true
  end

  # See if the file looks anything like what we are expecting
  def audit_sanity_check
    unless election_data_hash.has_key?("body") && election_data_hash["body"].has_key?("districts")
      raise ArgumentError, "Invalid format. No Body or Districts tag"
    end
    unless election_data_hash["body"]["districts"].reduce(true) { |memo, dist| dist.has_key?("ident") ? memo : false }
      raise ArgumentError, "Invalid format. All districts require a dent"
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
        audit_district_jurisdiction dist_index if @audit_type != :jurisdictions 
    end
  end
  
  # Check a particular District to make sure the Jurisdiction is valid.
  # Note that when auditing for jurisdiction import, this check is not needed, because import
  # target pre-specified.s
  def audit_district_jurisdiction dist_index
    return if @audit_type == :jurisdiction
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
