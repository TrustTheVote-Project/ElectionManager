require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class ImportEDH
    attr_reader :hash, :election

    # <tt>hash::</tt> Hash containing ElectionManager data. Has been processed for errors.
    def initialize(hash)
      @hash = hash
      @jurisdictions = []
      @precinct_id_map = {}
    end
    
    def import
      @hash["body"]["jurisdictions"].each { |juris| load_jurisdiction juris }
      @hash["body"]["precincts"].each { |prec| load_precinct prec}
      @hash["body"]["districts"].each { |dist| load_district dist}
      @hash["body"]["candidates"].each { |cand| load_candidate cand}
      @hash["body"]["candidates"].each { |elec| load_election elec}
    end
    
    def load_jurisdiction jurisdiction
      @jurisdictions << DistrictSet.find_or_create_by_display_name(jurisdiction["display_name"])
    end
    
    # load a single precinct into ElectionManager
    # <tt>precinct::</tt> hash representing a single precinct
    def load_precinct precinct
      # First find or create the precinct
      new_precinct = Precinct.find_or_create_by_display_name(precinct["display_name"])
      
      # For later lookups during district import, map precinct "ident" to object
      @precinct_id_map[precinct["ident"]] = new_precinct
    end
    
    def load_district district
      # Use precinct ident map, generate district ident map
    end
    
    def load_candidate candidate
      
    end

    def load_election election
      
    end
    
    def load_contest contest
      # Use district ident map
    end
  end
end