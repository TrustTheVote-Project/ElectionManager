require 'yaml'
module TTV

  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class YAMLExport
    attr_reader :election, :election_hash, :audit_header_hash
  
  # <tt>election::</tt> Election object to be exported
    def initialize(election)
      @elec = election
    end
  
  # Do the whole export process. Main entry point. Returns Yaml object ready to be saved.
  #
    def do_export 
      precinct_list_h = export_district_set(@elec)
      contests_h = export_contests(@elec)
      @election_hash = {"display_name" => @elec.display_name, 
                 "start_date" => @elec.start_date,
                 "contest_list" => contests_h,
                 "precinct_list" => precinct_list_h,
                 "jurisdiction_display_name" =>  @elec.display_name,
                 "number_of_precincts" => precinct_list_h.length
              }
     end
    
#
# Convert contest to a hash which can be converted to yaml directly.
# <tt>election:</tt>  Election object
# returns: an array containing the contests which can be converted to yaml for export
#
    def export_contests(election)
      contests_h = []
      election.contests.each do |cont|
        new_cont_h = {"display_name" => cont.display_name, 
                      "candidates" => export_candidates(cont), 
                      "district_ident" => @district_to_ident_map[cont.district],
                      "ident" => "cont-#{cont.id}"}
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
        candidates_h << {"display_name" => cand.display_name, "ident" => "cand-#{cand.id}", "party_ident" => "party-xxx" }
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

