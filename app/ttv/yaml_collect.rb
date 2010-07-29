require 'yaml'

module TTV
  # Construct an object hash and alerts from YAML-based ballot
  class YAMLCollect
    attr_reader :yaml_election, :object_hash

# <tt>source::</tt> File object for file containing yaml text
    def initialize(source)
      @source = source
      @yaml_election = YAML.load(@source)
      @object_hash = {}
      @object_hash[:candidates] = []
      @district_precinct_map = {}
    end
   
    def collect
      @object_hash[:type] = @yaml_election["audit_header"]["type"] if @yaml_election && @yaml_election["audit_header"] && @yaml_election["audit_header"]["type"]
      if @yaml_election && @yaml_election["ballot_info"]
        
        @object_hash[:jurisdiction] = @yaml_election["ballot_info"]["jurisdiction_display_name"] if @yaml_election["ballot_info"]["jurisdiction_display_name"]
        @object_hash[:election] = @yaml_election["ballot_info"]["display_name"] if @yaml_election["ballot_info"]["display_name"]
        
        collect_precincts
          # collect_districts
            # generate district idents
        collect_contests
        collect_questions
      end
      
      @object_hash
    end
  
    def collect_contests
      contests = []
      if @yaml_election["ballot_info"]["contest_list"]
        @yaml_election["ballot_info"]["contest_list"].each { |contest_hash|
          collected_contest = {}
          collected_contest[:order] = contest_hash["order"] if contest_hash["order"]
          collected_contest[:display_name] = contest_hash["display_name"] if contest_hash["display_name"]
          collected_contest[:district] = district_id_to_ident contest_hash["district_ident"] if contest_hash["district_ident"] && district_id_to_ident(contest_hash["district_ident"])
          collected_contest[:candidates] = collect_contest_candidates contest_hash["candidates"] if contest_hash["candidates"]
          contests << collected_contest
        }
      end
      @object_hash[:contests] = contests
    end
    
    def collect_contest_candidates candidate_list
      return_list = []
      candidate_list.each {|candidate|
        collected_candidate = {}
        collected_candidate[:order] = candidate["order"] if candidate["order"]
        collected_candidate[:ident] = find_or_create_candidate(candidate["display_name"], candidate["party_display_name"])[:ident] if candidate["display_name"] && candidate["party_display_name"]
        return_list << collected_candidate
      }
      return_list
    end
    
    def find_or_create_candidate name, party_name
      result = @object_hash[:candidates].find {|cand| cand[:display_name] == name and cand[:party_ident] == party_name_to_ident(party_name)} if @object_hash[:candidates]
      return result if result
      return create_candidate(name, party_name) unless result 
    end
    
    def create_candidate name, party_name
      candidate = {}
      candidate[:display_name] = name
      candidate[:ident] = gen_ident
      candidate[:party_ident] = find_or_create_party party_name
      
      @object_hash[:candidates] << candidate 
      
      candidate
    end
    
    def collect_questions
      
    end
  
    def collect_precincts
      
    end
    
    def collect_districts district_list

    end

    def gen_ident
      ActiveSupport::SecureRandom.hex
    end
    
    def district_id_to_ident
    
    end
  
    def find_or_create_party name
      
    end
    
    def party_name_to_ident name
      gen_ident # TODO: For testing candidates. Make valid when find_or_create_party is finished 
    end
  
  end
end