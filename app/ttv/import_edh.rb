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
      load_district_sets
      load_elections
      load_precinct_splits
      load_candidates
      load_contests
      # load_questions
    end
    
    def import_to_jurisdiction jur
      @jurisdiction = jur
      load_districts
      load_precincts
      load_district_sets
      load_elections
      load_precinct_splits
      load_candidates
      load_contests
      # load_questions
    end        
    
    # Imports all jurisdictions contained in the EDH
    def load_jurisdictions      
      @hash["body"]["jurisdictions"].each { |juris| load_jurisdiction juris } if @hash["body"].has_key? "jurisdictions"
    end
    
    # Imports all districts contained in the EDH
    def load_districts
      @hash["body"]["districts"].each { |dist| load_district dist} if @hash["body"].has_key? "districts"
    end
    
    # Imports all precincts contained in the EDH
    def load_precincts
      @hash["body"]["precincts"].each { |prec| load_precinct prec} if @hash["body"].has_key? "precincts"
    end
    
    # Imports all candidates contained in the EDH
    def load_candidates
      @hash["body"]["candidates"].each { |cand| load_candidate cand} if @hash["body"].has_key? "candidates"
    end  
    
    # Imports all contests contained in the EDH
    def load_contests
      @hash["body"]["contests"].each { |cont| load_contest cont} if @hash["body"].has_key? "contests"
    end
    
    # Imports all elections contained in the EDH
    def load_elections
      @hash["body"]["elections"].each { |elec| load_election elec} if @hash["body"].has_key? "elections"
    end
    
    def load_precinct_splits
      @hash["body"]["splits"].each { |split| load_precinct_split split } if @hash["body"].has_key? "splits"
    end
    
    # Imports all district_sets contained in the EDH
    def load_district_sets
      @hash["body"]["district_sets"].each { |dset| load_district_set dset} if @hash["body"].has_key? "district_sets"
    end 
        
    # Loads an EDH formatted jurisdiction into EM
    def load_jurisdiction jurisdiction
      new_jurisdiction = DistrictSet.find_or_create_by_ident(:display_name => jurisdiction["display_name"], :ident => jurisdiction["ident"])
      new_jurisdiction.save!
    end
    
    # Loads an EDH formatted district into EM
    def load_district district
      if district["type"] and DistrictType.find_by_title(district["type"])
        district_type = DistrictType.find_by_title(district["type"])
      else
        district_type = DistrictType.find(0) # Built-in default district type. TODO: Other better default in db/seed/once/district_types.yml?
      end
      new_district = District.find_or_create_by_ident(:display_name => district["display_name"], :ident => district["ident"], :district_type => district_type)
# TODO: When we have an actual Jurisdiction model, @jurisdiciton.class != DistrictSet 
      if @jurisdiction
        new_district.jurisdiction = @jurisdiction
      end
      new_district.save!
    end

    # Loads an EDH formatted precinct into EM
    def load_precinct precinct
      @jurisdiction ||= DistrictSet.find_by_ident(precinct["jurisdiction_ident"])
      new_precinct = Precinct.find_or_create_by_ident(:display_name => precinct["display_name"], 
                                                      :ident => precinct["ident"], 
                                                      :jurisdiction => @jurisdiction)
      new_precinct.save!
    end
    
    # Load an EDH formatted precinct split into EM
    def load_precinct_split split
      dist_set = DistrictSet.find_by_ident(split["district_set_ident"])
      prec = Precinct.find_by_ident(split["precinct_ident"])
      PrecinctSplit.create!(:district_set => dist_set, :precinct => prec)
    end
    
    # Load an EDH formatted district_set into EM
    def load_district_set distset
      if !DistrictSet.find_by_ident(distset["ident"])
        ds_new = DistrictSet.create!(:ident => distset["ident"])
        distset["district_list"].each { |ds| ds_new.districts << District.find_by_ident(ds["district_ident"])}
        ds_new.save!
      end
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
      new_contest = Contest.find_or_create_by_ident(:display_name => contest["display_name"], 
                                                    :ident => contest["ident"], 
                                                    :voting_method_id => voting_method_id, 
                                                    :district => District.find_by_ident(contest["district_ident"]))
      contest["candidates"].each{ |cand| new_contest.candidates << Candidate.find_by_ident(cand["candidate_ident"])} if contest["candidates"]
      new_contest.election = Election.find_by_ident(contest["election_ident"])
      new_contest.save!
    end

    # Loads an EDH formatted election into EM
    def load_election election
      new_election = Election.find_or_create_by_ident(
          :display_name => election["display_name"], 
          :district_set_id => DistrictSet.find_by_ident(election["jurisdiction_ident"]).id, 
          :ident => election["ident"], 
          :start_date => election["start_date"])      
      new_election.save!
    end      
  end
end