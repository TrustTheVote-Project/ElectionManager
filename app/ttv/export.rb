require 'yaml'
module TTV

  # Contains methods to export stored ElectionManager data as YAML, XML
  class Export
    attr_reader :election_data_hash, :audit_header_hash
  
    # Create export object. 
    def initialize
    end
  
    # Construct election data hash for a particular jurisdiction
    def export_jurisdiction jurisdiction, format
      @precinct_idents_exported = []
      @election_idents_exported = []
      @contest_idents_exported = []
      @candidate_idents_exported = []
      @election_data_hash = {"body" => {}, "audit_header" => {}}
      @election_data_hash["body"]["jurisdictions"] = [jurisdiction_hash jurisdiction]
      @election_data_hash["body"]["districts"] = districts_from_jurisdictions @election_data_hash["body"]["jurisdictions"] 
      @election_data_hash["body"]["precincts"] = precincts_from_districts @election_data_hash["body"]["districts"]
      @election_data_hash["body"]["elections"] = elections_from_jurisdictions @election_data_hash["body"]["jurisdictions"]
      @election_data_hash["body"]["contests"] = contests_from_elections @election_data_hash["body"]["elections"]
      @election_data_hash["body"]["candidates"] = candidates_from_contests @election_data_hash["body"]["contests"]
      # @election_data_hash["body"]["questions"] = questions_from_elections @election_data_hash["body"]["elections"]      
      
      @election_data_hash["audit_header"] = {"schema_version" => 0.1, "create_date" => Time.now.inspect,
                       "type" => "jurisdiction_slate", "operator" => "Pito Salas"}
      
      if format == :yaml
        @election_data_hash
      elsif format == :xml
        @xml_hash = {}
        @xml_hash = @election_data_hash
        xml_string = @xml_hash.to_xml({:dasherize=>false, :root => "ttv_object"})
        
        # Remove type="array" lines and their closing tags
        final_xml_string = ""
        xml_string.each_line { |line|
          if line.include?('type="array"') || line.include?("</precincts>") || line.include?("</districts>") ||
             line.include?("</jurisdictions>") || line.include?("</contests>") || line.include?("</candidates>") ||
             line.include?("</questions>") || line.include?("</elections>")
             # Do not add
          else # Add
            final_xml_string << line
          end
        }
        
        # puts final_xml_string
        final_xml_string
      end
    end
    
    # Return an EDH formatted jurisdiction
    def jurisdiction_hash jurisdiction
      return_hash = {}
      return_hash["display_name"] = jurisdiction.display_name
      return_hash["ident"] = jurisdiction.ident
      return_hash
    end
    
    # Return an array of EDH formatted districts given array of EDH jurisdictions
    def districts_from_jurisdictions jurisdictions_array
      # TODO: Support districts with multiple jurisdictions
      return_array = []
      jurisdictions_array.each { |jurisdiction| 
        DistrictSet.find_by_ident(jurisdiction['ident']).districts.each { |district| 
          return_district = {}
          return_district["display_name"] = district.display_name
          return_district["ident"] = district.ident
          return_district["type"] = district.district_type.title
          return_district["jurisdictions"] = [{"identref" => jurisdiction['ident']}]
          return_array << return_district
        }
      }
      return_array
    end
    
    # Return an array of EDH formatted precincts given array of EDH districts
    def precincts_from_districts districts_array
      return_array = []
      districts_array.each { |district_hash| 
        District.find_by_ident(district_hash['ident']).precincts.each { |precinct| 
          if @precinct_idents_exported.include? precinct.ident # Do nothing
          else
            @precinct_idents_exported << precinct.ident
            return_precinct = {}
            return_precinct["ident"] = precinct.ident
            return_precinct["display_name"] = precinct.display_name
            return_precinct["districts"] = []
            precinct.districts.each { |district| 
              return_precinct["districts"] << {"identref" => district.ident}
            }
            return_array << return_precinct
          end
        }
      }
      return_array
    end
    
    # Return an array of EDH formatted elections given array of EDH jurisdictions
    def elections_from_jurisdictions jurisdictions_array
      return_array = []
      jurisdictions_array.each { |jurisdiction| 
        DistrictSet.find_by_ident(jurisdiction['ident']).elections.each { |election| 
          if @election_idents_exported.include? election.ident # Do nothing
          else
            @election_idents_exported << election.ident
            return_election = {}
            return_election["ident"] = election.ident
            return_election["display_name"] = election.display_name
            return_election["start_date"] = election.start_date
            return_election["jurisdiction_identref"] = election.district_set.ident
            return_election["contests"] = []
            election.contests.each { |contest| 
              return_election["contests"] << {"identref" => contest.ident}
            }
            return_array << return_election
          end
        }
      }
      return_array
    end

    # Return an array of EDH formatted contests, given array of EDH elections
    def contests_from_elections elections_array
      return_array = []
      elections_array.each { |election| 
        Election.find_by_ident(election['ident']).contests.each { |contest| 
          if @contest_idents_exported.include? contest.ident # Do nothing
          else
            @contest_idents_exported << contest.ident
            return_contest = {}
            return_contest["ident"] = contest.ident
            return_contest["display_name"] = contest.display_name
            return_contest["voting_method"] = contest.voting_method.display_name
            return_contest["district_identref"] = contest.district.ident
            return_contest["candidates"] = []
            contest.candidates.each { |candidate| 
              return_contest["candidates"] << {"identref" => candidate.ident}
            }
            return_array << return_contest
          end
        }
      }
      return_array
    end

    # Return an array of EDH formatted candidates, given array of EDH contests
    def candidates_from_contests contests_array
      return_array = []
      contests_array.each { |contest| 
        Contest.find_by_ident(contest['ident']).candidates.each { |candidate| 
          if @candidate_idents_exported.include? candidate.ident # Do nothing
          else
            @candidate_idents_exported << candidate.ident
            return_candidate = {}
            return_candidate["ident"] = candidate.ident
            return_candidate["display_name"] = candidate.display_name
            return_candidate["party"] = candidate.party.display_name
            return_array << return_candidate
          end
        }
      }
      return_array
    end

  end
end

