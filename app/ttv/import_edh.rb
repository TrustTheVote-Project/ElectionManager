require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class ImportEDH
    attr_reader :hash, :election

    # <tt>hash::</tt> Hash containing ElectionManager data. Has been processed for errors.
    def initialize(hash)
      @hash = hash
      @jurisdictions = []
    end
    
    # Performs the import of all items contained within <tt>hash</tt>.
    def import
      load_jurisdictions
      load_districts
      load_precincts
      load_candidates
      load_contests
      load_elections
    end
    
    # Imports all jurisdictions contained in the EDH
    def load_jurisdictions
      @hash["body"]["jurisdictions"].each { |juris| load_jurisdiction juris }
    end
    
    # Imports all districts contained in the EDH
    def load_districts
      @hash["body"]["districts"].each { |dist| load_district dist}
    end
    
    # Imports all precincts contained in the EDH
    def load_precincts
      @hash["body"]["precincts"].each { |prec| load_precinct prec}
    end
    
    # Imports all candidates contained in the EDH
    def load_candidates
      @hash["body"]["candidates"].each { |cand| load_candidate cand}
    end  
    
    # Imports all contests contained in the EDH
    def load_contests
      @hash["body"]["contests"].each { |cont| load_contest cont}
    end
    
    # Imports all elections contained in the EDH
    def load_elections
      @hash["body"]["elections"].each { |elec| load_election elec}
    end
    
    # Loads an EDH formatted jurisdiction into EM
    def load_jurisdiction jurisdiction
      new_jurisdiction = DistrictSet.find_or_create_by_ident(:display_name => jurisdiction["display_name"], :ident => jurisdiction["ident"])
      new_jurisdiction.save!
      # This is a test
    end
    
    # Loads an EDH formatted district into EM
    def load_district district
      if district["type"] and DistrictType.find_by_title(district["type"])
        district_type = DistrictType.find_by_title(district["type"])
      else
        district_type = 0 # Built-in default district type. TODO: Other better default in db/seed/once/district_types.yml?
      end
      
      new_district = District.find_or_create_by_ident(:display_name => district["display_name"], :ident => district["ident"], :district_type => district_type)
# TODO: When district gets a link back to jurisdiction, this test can be reinstated.      
#      district["jurisdiction_ident"].each { |jurisdiction|
#        new_district.district_sets << DistrictSet.find_by_ident(jurisdiction["identref"])
#      }
      
      new_district.save!
    end

    # Loads an EDH formatted precinct into EM
    def load_precinct precinct
      new_precinct = Precinct.find_or_create_by_ident(:display_name => precinct["display_name"], :ident => precinct["ident"])
      precinct["districts"].each{|dist| new_precinct.districts << District.find_by_ident(dist["identref"]) if !new_precinct.districts.include? District.find_by_ident(dist["identref"])} if precinct["districts"]
      new_precinct.save!
    end
    
    # Loads an EDH formatted candidate into EM
    def load_candidate candidate
      new_candidate = Candidate.find_or_create_by_ident(:display_name => candidate["display_name"], :ident => candidate["ident"], :party_id => Party.find_or_create_by_display_name(candidate["party"]).id)
      new_candidate.save! 
    end
    
    # Loads an EDH formatted contest into EM
    def load_contest contest
      if contest["voting_method"] and VotingMethod.find_by_display_name(contest["voting_method"])
        voting_method_id = VotingMethod.find_by_display_name(contest["voting_method"]) 
      else
        voting_method_id = 0
      end
      
      new_contest = Contest.find_or_create_by_ident(:display_name => contest["display_name"], :ident => contest["ident"], :voting_method_id => voting_method_id, :district_id => District.find_by_ident(contest["district_identref"]).id)
      contest["candidates"].each{ |cand| new_contest.candidates << Candidate.find_by_ident(cand["identref"])} if contest["candidates"]
      new_contest.save!
    end

    # Loads an EDH formatted election into EM
    def load_election election
      new_election = Election.find_or_create_by_ident(:display_name => election["display_name"], :district_set_id => DistrictSet.find_by_ident(election["jurisdiction_identref"]).id, :ident => election["ident"], :start_date => election["start_date"])
      election["contests"].each{ |cont| new_election.contests << Contest.find_by_ident(cont["identref"])} if election["contests"]
      new_election.save!
    end
    
  end
end