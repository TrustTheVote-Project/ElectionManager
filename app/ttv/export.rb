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
      @election_data_hash = {"body" => {}, "audit_header" => {}}
      @election_data_hash["body"]["jurisdictions"] = [jurisdiction_hash jurisdiction]
      @election_data_hash["body"]["districts"] = districts_from_jurisdictions @election_data_hash["body"]["jurisdictions"] 
      @election_data_hash["body"]["precincts"] = precincts_from_districts @election_data_hash["body"]["districts"]
=begin
      @election_data_hash["body"]["elections"] = elections_from_jurisdictions @election_data_hash["body"]["jurisdictions"]
      @election_data_hash["body"]["contests"] = contests_from_elections @election_data_hash["body"]["elections"]
      @election_data_hash["body"]["questions"] = questions_from_elections @election_data_hash["body"]["elections"]
      @election_data_hash["body"]["candidates"] = candidates_from_contests @election_data_hash["body"]["contests"]
=end      
      @election_data_hash["audit_header"] = {"schema_version" => 0.1, "create_date" => Time.now.inspect,
                       "type" => "jurisdiction_slate", "operator" => "Pito Salas"}
      
      if format == :yaml
        @election_data_hash
      elsif format == :xml
        @xml_hash = {}
        @xml_hash["ttv_object"] = @election_data_hash
        @xml_hash.to_xml
      end
    end
    
    def jurisdiction_hash jurisdiction
      return_hash = {}
      return_hash["display_name"] = jurisdiction.display_name
      return_hash["ident"] = jurisdiction.ident
      return_hash
    end
    
    def districts_from_jurisdictions jurisdictions_array
      return_array = []
      jurisdictions_array.each { |jurisdiction| 
        DistrictSet.find_by_ident(jurisdiction['ident']).districts.each { |district| 
          return_district = {}
          return_district["display_name"] = district.display_name
          return_district["ident"] = district.ident
          return_district["type"] = district.district_type.title
          return_district["jurisdiction_identref"] = jurisdiction['ident']
          return_array << return_district
        }
      }
      return_array
    end
    
    def precincts_from_districts districts_array
      return_array = []
      districts_array.each { |district_hash| 
        District.find_by_ident(district_hash['ident']).precincts.each { |precinct| 
          return_precinct = {}
          # TODO: Check for previous precincts
          return_precinct["ident"] = precinct.ident
          return_precinct["display_name"] = precinct.display_name
          return_precinct["districts"] = []
          precinct.districts.each { |district| 
            return_precinct["districts"] << {"district_identref" => district.ident}
          }
          return_array << return_precinct
        }
      }
      return_array
    end
  end
end

