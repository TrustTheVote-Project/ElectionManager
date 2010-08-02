require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class ImportEDH
    attr_reader :hash, :election

    # <tt>hash::</tt> Hash containing ElectionManager data. Has been processed for errors.
    def initialize(hash)
      @hash = hash
      @jurisdiction = nil
      @dist_id_map = {}
    end
    
    def import
      load_jurisdiction
      @hash["ballot_info"]["precinct_list"].each { |prec| load_precinct prec}
    end
    
    def load_jurisdiction
      @jurisdiction = DistrictSet.find_or_create_by_display_name(@hash["ballot_info"]["jurisdiction_display_name"])
    end
    
    # load a single precinct into ElectionManager
    # <tt>precinct::</tt> hash representing a single precinct
    def load_precinct precinct
      # First find or create the precinct
      prec_disp_name = precinct["display_name"]
      new_precinct = Precinct.find_or_create_by_display_name(prec_disp_name)
      
      if precinct.key? "district_list"
        load_districts precinct["district_list"], new_precinct 
      end
    end
    
    # find or create a list of districts.
    # <tt>district_list::</tt> district_list from hash
    # <tt>precinct::</tt> ElectionManager precinct object associated with district_list
    def load_districts district_list, precinct
      district_list.each do |district_hash|
        dist_disp_name = district_hash["display_name"]
        district = District.find_or_create_by_display_name(dist_disp_name)
        
        # Add this district to the district set we're working with, and to the precinct being built
        @jurisdiction.districts << district
        district.precincts << precinct

        # For later lookups during contest/question import, record which district "ident" represents which District object
        @dist_id_map[district_hash["ident"]] = district
      end
    end
  end
end