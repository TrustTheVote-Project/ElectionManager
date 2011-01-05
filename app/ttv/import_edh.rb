require 'yaml'

module TTV
  # Import Election Data Hash (EDH) and convert as needed to Election and related objects.
  class ImportEDH

    attr_reader :hash, :election
    
    def l (string)
      Rails.logger.debug string
    end


    # <tt>import_type:</tt> is "jurisdiction_info", "election_info" or "candidate_info"
    # <tt>hash::</tt> Hash containing `ElectionManager data. Has been processed for errors.
    #
    def initialize(import_type, hash)
      @hash = hash
      @import_type = import_type
      @jurisdictions = []
    end
    
    # Performs the import of all items in EDH
    # <tt>jur:</tt>Jurisdition to use as context
    def import jur
      @jurisdiction = jur

      if @import_type.eql? "jurisdiction_info"
        load_districts
        load_precincts
        load_district_sets
        load_precinct_splits
      elsif @import_type.eql? "election_info"
        load_elections
        load_contests
        load_questions
      elsif @import_type.eql? "candidate_info"
        load_candidates
      end
    end

    # Imports all jurisdictions contained in the EDH
    def load_jurisdictions      
      @hash["body"]["jurisdictions"].each { |juris| load_jurisdiction juris } if @hash["body"].has_key? "jurisdictions"
    end
    
    # Loads an EDH formatted jurisdiction into EM
    def load_jurisdiction jurisdiction
      new_jurisdiction = DistrictSet.find_or_create_by_ident(:display_name => jurisdiction["display_name"], :ident => jurisdiction["ident"])
      new_jurisdiction.save!
    end
    
    # Imports all districts contained in the EDH
    def load_districts
      @hash["body"]["districts"].each { |dist| load_district dist} if @hash["body"].has_key? "districts"
    end
    
    # Loads an EDH formatted district into EM
    def load_district district
      new_district = District.find_or_create_by_ident(:display_name => district["display_name"], :ident => district["ident"])
      new_district.district_type = DistrictType.find_or_create_by_title(district["type"])

# TODO: When we have an actual Jurisdiction model, @jurisdiciton.class != DistrictSet 
      if @jurisdiction
        new_district.jurisdiction = @jurisdiction
      end
      new_district.save!
    end


    
    # Imports all precincts contained in the EDH
    def load_precincts
      @hash["body"]["precincts"].each { |prec| load_precinct prec} if @hash["body"].has_key? "precincts"
    end
    
    # Imports all candidates contained in the EDH
    def load_candidates
      @hash["body"]["candidates"].each { |cand| load_candidate cand} if @hash["body"].has_key? "candidates"
    end
    
    # Imports all questions contained in the EDH
    def load_questions
      @hash["body"]["questions"].each { |question| load_question question} if @hash["body"].has_key? "questions"
    end
    
    # Import a question from EDH into EM database
    def load_question question
      new_question = Question.find_or_create_by_ident(:display_name => question["display_name"],
                                                      :ident => question["ident"],
                                                      :question => question["question"])
      new_question.requesting_district = District.find_by_ident(question["district_ident"])                                                      
      new_question.election = Election.find_by_ident(question["election_ident"])
      new_question.save!
    end
    
    # Imports all contests contained in the EDH
    def load_contests
      @hash["body"]["contests"].each { |cont| load_contest cont} if @hash["body"].has_key? "contests"
    end
    
    # Loads an EDH formatted contest into EM
    def load_contest contest
      if contest["voting_method"] and VotingMethod.find_by_display_name(contest["voting_method"])
        voting_method_id = VotingMethod.find_by_display_name(contest["voting_method"]) 
      else
        voting_method_id = VotingMethod.find_by_display_name("Winner Take All")
      end
      new_contest = Contest.find_or_create_by_ident(:display_name => contest["display_name"], 
                                                    :ident => contest["ident"], 
                                                    :voting_method_id => voting_method_id, 
                                                    :district => District.find_by_ident(contest["district_ident"]))
      contest["candidates"].each{ |cand| new_contest.candidates << Candidate.find_by_ident(cand["candidate_ident"])} if contest["candidates"]
      new_contest.election = Election.find_by_ident(contest["election_ident"])
      new_contest.save!
    end

    # Imports all elections contained in the EDH
    def load_elections
      @hash["body"]["elections"].each { |elec| load_election elec} if @hash["body"].has_key? "elections"
    end
    
    # Loads an EDH formatted election into EM
    def load_election election
      new_election = Election.find_or_create_by_ident(
          :display_name => election["display_name"], 
          :ident => election["ident"], 
          :start_date => election["start_date"])
      new_election.district_set = @jurisdiction
      new_election.save!
    end      
    
    def load_precinct_splits
      @hash["body"]["splits"].each { |split| load_precinct_split split } if @hash["body"].has_key? "splits"
    end
    
    # Load an EDH formatted PrecinctSplit into EM. The PrecinctSplit's display_name is the
    # Associated DistrictSet's ident. We know that PrecinctSplit : DistrictSet is 1:1
    def load_precinct_split split
      dist_set = DistrictSet.find_by_ident(split["district_set_ident"])
      prec = Precinct.find_by_ident(split["precinct_ident"])
# TODO: rps: PrecinctSplit should have an ident column
      PrecinctSplit.find_or_create_by_display_name(:display_name => split["display_name"], :district_set => dist_set, :precinct => prec)
    end    
    
    # Imports all district_sets contained in the EDH
    def load_district_sets
      @hash["body"]["district_sets"].each { |dset| load_district_set dset} if @hash["body"].has_key? "district_sets"
    end 

    # Load an EDH formatted district_set into EM
    def load_district_set distset
      if !DistrictSet.find_by_ident(distset["ident"])
        ds_new = DistrictSet.create!(:ident => distset["ident"])
        distset["district_list"].each { |ds| ds_new.districts << District.find_by_ident(ds["district_ident"])}
        ds_new.save!
      end
    end
    
    # Loads an EDH formatted precinct into EM
    def load_precinct precinct
      @jurisdiction ||= DistrictSet.find_by_ident(precinct["jurisdiction_ident"])
      new_precinct = Precinct.find_or_create_by_ident(:display_name => precinct["display_name"], 
                                                      :ident => precinct["ident"])
      new_precinct.jurisdiction = @jurisdiction                                                
      new_precinct.save!
        l "*** after new_precinct_save: #{new_precinct.inspect}"
        l "    #{new_precinct.jurisdiction.inspect}\n\n"
    end

    
    # Loads an EDH formatted candidate into EM
    def load_candidate candidate
      party_name = candidate["party_display_name"] || "none specified"
      new_candidate = Candidate.find_or_create_by_ident(:display_name => candidate["display_name"], 
                                                        :ident => candidate["ident"],
                                                        :position => candidate["position"],
                                                        :party_id => Party.find_or_create_by_display_name(party_name).id)
      new_candidate.contest = Contest.find_by_ident(candidate["contest_ident"])
      new_candidate.save! 
    end
    
  end
end
