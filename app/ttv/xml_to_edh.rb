require 'yaml'

module TTV
  # Convert XML to the Election Data Hash format
  class XMLToEDH
    attr_reader :election_data_hash, :xml, :xml_hash

    # <tt>xml::</tt> XML containing ElectionManager data
    def initialize(xml)
      @xml = xml
      @xml_hash = Hash.from_xml(xml)
      @election_data_hash = {"audit_header" => {}, "ballot_info" => {}}
     #@dist_id_map = {}
    end
    
    def convert
      if @xml_hash["election"]
        if @xml_hash["election"]["districts"]
          convert_districts @xml_hash["election"]["districts"] 
        end
      end
    end
    
    def convert_districts districts
      # 1. Convert jurisdiction display name, if defined
      @election_data_hash["ballot_info"]["jurisdiction_display_name"] = districts["display_name"] if districts["display_name"]
      
      # 2. For each district defined, place full district EDH-formatted definition in precinct-keyed hash
      
    end
    
  end
end