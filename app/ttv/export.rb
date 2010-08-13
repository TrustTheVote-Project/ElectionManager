require 'yaml'
module TTV

  # Contains methods to export stored ElectionManager data as YAML, XML
  class Export
    attr_reader :election_data_hash, :audit_header_hash
  
    # Create export object. 
    def initialize
    end
  
    # Construct election data hash for a particular jurisdiction
    def export_jurisdiction jurisdiction
      @election_data_hash = {"body" => {}, "audit_header" => {}}
      @election_data_hash["body"]["jurisdictions"] = [jurisdiction_hash jurisdiction]
      @election_data_hash["body"]["districts"] = districts_from_jurisdictions_array @election_data_hash["body"]["jurisdictions"] 
      @election_data_hash["body"]["precincts"] = precincts_from_districts_array @election_data_hash["body"]["districts"]
      @election_data_hash["body"]["elections"] = elections_from_jurisdictions_array @election_data_hash["body"]["jurisdictions"]
      @election_data_hash["body"]["contests"] = contests_from_elections_array @election_data_hash["body"]["elections"]
      @election_data_hash["body"]["questions"] = questions_from_elections_array @election_data_hash["body"]["elections"]
      @election_data_hash["body"]["candidates"] = candidates_from_contests_array @election_data_hash["body"]["contests"]
      
      @election_data_hash["audit_header"] = {"schema_version" => 0.1, "create_date" => Time.now.inspect,
                       "type" => "jurisdiction_slate", "operator" => "Pito Salas"}
     end
    
    # Convert questions to an array of EDH elements
    # <tt>elections:</tt> an array of elections in EDH format
    # returns: an array containing the questions in EDH format
    def export_questions_from_elections_array elections
      questions_h = []
      election.questions.each {|question|
        new_question_h = {"display_name" => question.display_name,
                          "question" => question.question,
                          "district_ident" => @district_to_ident_map[question.requesting_district]}
        questions_h << new_question_h
      }
      questions_h
    end
    
#
# Convert contests to a hash which can be converted to yaml directly.
# <tt>election:</tt>  Election object
# returns: an array containing the contests which can be converted to yaml for export
#
    def export_contests(election)
      contests_h = []
      election.contests.each do |cont|
        new_cont_h = {"display_name" => cont.display_name, 
                      "candidates" => export_candidates(cont), 
                      "district_ident" => @district_to_ident_map[cont.district],
                      "ident" => "cont-#{cont.id}",
                      "display_order" => cont.position}
        contests_h << new_cont_h
      end
      contests_h
    end
  
#
# Convert the list of candidates for a contest to a hash
# <tt>contest::</tt>  Contest object
# returns: an array containing the candidates for this contest, ready to be ecported to yaml
#
    def export_candidates(a_contest)
      candidates_h = []
      a_contest.candidates.each do |cand| 
        candidates_h << {"display_name" => cand.display_name, "ident" => "cand-#{cand.id}", "party_display_name" => cand.party.display_name, "party_ident" => "party-#{cand.party.id}" }
      end
      candidates_h
    end
  
# 
# Note in the yaml format precinct_set is pivoted into a precinct_list, and each precinct has a list
# of districts. It's really the same information folded a different way.
# <tt>election::</tt> Election object
# returns:: an array with all the precincts corresponding to this election  
    def export_district_set(election)
#
# Go through all the districts in the distrset and fill in two hashes.
# @district_to_ident_map[dist] = :dist_ident for each district that is mentioned in the districtsets associated with the election. (dist_ident
# precincts_already_processed[prec] = an array of all the district objects that are in the indicated precinct.
#
      @district_to_ident_map = {}
      precinct_to_distlist = {}
      election.district_set.districts.each do |dist|
        if !@district_to_ident_map[dist]
          @district_to_ident_map[dist] = "dist-#{dist.id}"          
          dist.precincts.each do |a_prec|
            if !precinct_to_distlist[a_prec]
              precinct_to_distlist[a_prec] = [dist]
            else
              precinct_to_distlist[a_prec] << dist
            end
          end
        end
      end
#
# Generate a hash (precinct_list_h) representing the precincts.
#
      precinct_list_a = []
      precinct_to_distlist.each do |prec, districts|
        precinct_h = {}
        precinct_h["display_name"] = prec.display_name
        precinct_h["ident"] = "prec-#{prec.id}"
        precinct_h["voting_places"] = [{"ballot_counters" => 2, "ident" => "vplace-xxx"}]
        district_list_a = []
        districts.each do |dist|
          district_h = {"display_name" => dist.display_name, "ident" => @district_to_ident_map[dist]}
          district_list_a << district_h
        end
        precinct_h["district_list"] = district_list_a
        precinct_list_a << precinct_h
      end
      precinct_list_a
    end
  end
end

