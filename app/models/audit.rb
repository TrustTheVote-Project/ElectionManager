# == Schema Information
# Schema version: 20100802153118
#
# Table name: audits
#
#  id                 :integer         not null, primary key
#  display_name       :string(255)
#  election_data_hash :text
#  created_at         :datetime
#  updated_at         :datetime
#  district_set_id    :integer
#

class Audit < ActiveRecord::Base
  serialize :election_data_hash # TODO: find maximum size for serialize
  attr_accessible :display_name, :election_data_hash, :district_set, :district_set_id
  
  has_many :alerts
  
  belongs_to :district_set

  # Applies transforms to @hash based on alerts
  def apply_alerts
    alerts.each{ |alert|
      if alert.alert_type == "no_jurisdiction" && alert.choice == "use_current"
        election_data_hash["ballot_info"]["jurisdiction_display_name"] = district_set.display_name
        self.save!
        alerts.delete(alert)
      end
    }
  end

  # Audits election_data_hash (without touching it), producing more @alerts
  def audit
    @audit_in_progress = true
    
    audit_jurisdictions # Collect IDs of new jurisdictions and EM-imported jurisdictions
    audit_precincts # Collect IDs (so we know which ones are valid for districts)
    audit_districts 
    audit_candidates
    audit_contests
    
    @audit_in_progress = false
    @audited = true
  end
  
  def audit_jurisdictions
    # For each jurisdiction in election_data_hash["ballot_info"]["jurisdictions"], store ident
    
    # For each jurisdiction in EM DistrictSets.all.each { |district_set| # store ident }
  end
  
  def audit_precincts
    # For each precinct in election_data_hash["ballot_info"]["precincts"], store ident with display_name
      # After district audit, look for unattached precincts
  end
  
  def audit_candidates
    
  end
  
  def audit_contests
    
  end
  
  def audit_districts
    puts election_data_hash.to_yaml
    election_data_hash["body"]["districts"].each{ |district|
      puts district.to_yaml if district
      if district && !district["jurisdiction_identref"]
        alerts << Alert.new(:message => "No jurisdiction specified for district #{district["display_name"]}", :alert_type => "no_jurisdiction", :object => district["ident"].to_s, :options => 
          {"use_current" => "Use current jurisdiction #{district_set.display_name}", "import" => "Import without a jurisdiction", "abort" => "Abort import"}, :default_option => "use_current")
      end
    }
  end
  
  def ready_for_import? # TODO: add check for whether audit's been done
    return ((alerts.size == 0) && !@audit_in_progress && @audited)
  end

end
