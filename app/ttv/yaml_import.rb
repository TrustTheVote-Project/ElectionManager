require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class YAMLImport
    attr_reader :yml_election, :election, :dist_set

# <tt>source::</tt> File object for file containing yaml text
    def initialize(source)
      @source = source
    end
  
#
# Is the .yml being imported of type 'ballot_config"? Ballot_config's have less stringent
# validation and get connected to the 'default built-in district' etc.
    def ballot_config?
      if @yml_election["audit_header"].nil?
        return false
      else
        return @yml_election["audit_header"]["type"] == "ballot_config"
      end
    end

# Do the whole import process. Main entry point.
    def import
      @dist_id_map = {}
      @yml_election = YAML.load(@source)
      ActiveRecord::Base.transaction do
        @dist_set = create_district_set
        if @yml_election["ballot_info"].nil?
          puts "No ballot information -- invalid yml"
          pp @yml_election
          raise "Invalid YAML election. See console for details."
        end
        @election = Election.create(:display_name => @yml_election["ballot_info"]["display_name"])
        if @yml_election["ballot_info"]["start_date"].nil?
             @election.start_date = Time.now
        else
          @election.start_date = Date.parse(@yml_election["ballot_info"]["start_date"].to_s)
        end
        @election.district_set = @dist_set
        @election.save
        if @yml_election["ballot_info"]["precinct_list"].nil?
            puts "Invalid yml doesn't contain precinct_list"
            pp @yml_election
            raise "Invalid YAML election. See console for details."
        elsif @yml_election["ballot_info"]["contest_list"].nil?          
            puts "Invalid yml doesn't contain contest_list"
            pp @yml_election
            raise "Invalid YAML election. See console for details."
        end
        @yml_election["ballot_info"]["precinct_list"].each { |prec| load_precinct prec}            
        @yml_election["ballot_info"]["contest_list"].each { |yml_contest| load_contest yml_contest}
        @yml_election["ballot_info"]["question_list"].each { |yml_question| load_question yml_question} unless @yml_election["ballot_info"]["question_list"].nil?
      end
      @election
    end
    
    
    def import_batch
        @dist_id_map = {}
        yaml_dir = Dir.new(@source)
        yaml_dir.each do |yaml_file|
          if yaml_file[yaml_file.length - 3..yaml_file.length] == 'yml'
            new_file = File.new("#{@source}/#{yaml_file}", "r")
            @yml_election = YAML.load(new_file)
            ActiveRecord::Base.transaction do
              @dist_set = create_district_set
              if @yml_election["ballot_info"].nil?
                puts "No ballot information -- invalid yml"
                pp @yml_election
                raise "Invalid YAML election. See console for details."
              end
               @election = Election.create(:display_name =>@yml_election["ballot_info"]["display_name"])
                if @yml_election["ballot_info"]["start_date"].nil?
                      @election.start_date = Time.now
                 else
                   @election.start_date = Date.parse(@yml_election["ballot_info"]["start_date"].to_s)
                 end

                @election.district_set = @dist_set
                @election.save
                if @yml_election["ballot_info"]["precinct_list"].nil?
                    puts "Invalid yml doesn't contain precinct_list"
                    pp @yml_election
                    raise "Invalid YAML election. See console for details."
                elsif @yml_election["ballot_info"]["contest_list"].nil?          
                    puts "Invalid yml doesn't contain contest_list"
                    pp @yml_election
                    raise "Invalid YAML election. See console for details."
                end
                @yml_election["ballot_info"]["precinct_list"].each { |prec| load_precinct prec}            
                @yml_election["ballot_info"]["contest_list"].each { |yml_contest| load_contest(yml_contest)}
                @yml_election["ballot_info"]["question_list"].each { |yml_question| load_question yml_question} unless @yml_election["ballot_info"]["question_list"].nil?
                end
                @election
          end
        end
    end

    def create_district_set
      if ballot_config?
        DistrictSet.find(0)
      else
        DistrictSet.create(:display_name => @yml_election["ballot_info"]["jurisdiction_display_name"])
      end
    end
    
# load another question into Election object
# <tt>question::</tt>Hash contains single question from yaml
    def load_question yml_question
      if ballot_config?
        dist = District.find(0)
      else
        if yml_question["district_ident"].nil? || @dist_id_map[yml_question["district_ident"]].nil?
          puts "Error in yaml_import: invalid question"
          pp yml_cont
          raise "Invalid yaml in question. See console for details."
        end
        dist = @dist_id_map[yml_question["district_ident"]]
      end
      new_question = Question.create(:display_name =>yml_question["display_name"],
                                   :question => yml_question["question"])
      
      #new_question.order = yml_question["order"] || 0
      # TODO: add order support to question model
      
      @election.questions << new_question
      new_question.save
      dist.questions << new_question
    end
    
# load another contest into Election object
# <tt>contest::</tt>Hash contains single contest from yaml
    def load_contest yml_cont
      if @dist_id_map[yml_cont["district_ident"]].nil?
        # the only time we can survive without district and precinct lists is with ballot_config.
        if ballot_config?
          dist = District.find(0)
        else
          puts "Error in yaml_import: invalid contest"
          pp yml_cont
          raise "Invalid yaml in contest. See console for details."
        end
      else
        dist = @dist_id_map[yml_cont["district_ident"]]
      end

      new_contest = Contest.create(:display_name =>yml_cont["display_name"],
                                   :open_seat_count => 1, :voting_method_id => 0)
                                   
      if yml_cont.key? "voting_method"
        new_contest.voting_method_id = VotingMethod.xmlToId(yml_cont["voting_method"])
      else # default if none specified
        new_contest.voting_method_id = VotingMethod::WINNER_TAKE_ALL
      end
      new_contest.order = yml_cont["display_order"] || 0
      yml_cont["candidates"].each { |yml_cand| load_candidate yml_cand, new_contest }
      @election.contests << new_contest
      new_contest.save
      dist.contests << new_contest
     end
    
  # load another candidate
  # <tt>cand::</tt>Hash containing a single candidate from yaml
    def load_candidate y_cand, cont
      new_cand = Candidate.create(:display_name => y_cand["display_name"])
      party_name = y_cand["party_display_name"]

      party = Party.find_by_display_name(party_name)
      if party.nil? 
        party = Party.new(:display_name => party_name)
      end
      new_cand.party = party
      
      new_cand.order = y_cand["order"] || 0
      cont.candidates << new_cand
    end
    
# load another precinct into Election object
# <tt>precinct::</tt>Hash contains a single precinct from yaml
    def load_precinct yaml_prec
# First find or create the precinct
      prec_disp_name = yaml_prec["display_name"]
      new_precinct = Precinct.find_by_display_name(prec_disp_name)
      if !new_precinct
        new_precinct = Precinct.create(:display_name => prec_disp_name)
      end
      if !yaml_prec.key? "district_list"
# if so, just connect precinct to the built-in default district
        District.find(0).precincts << new_precinct
      else
# otherwise connect the new precinct to each of the districts in its district_list
        load_districts yaml_prec["district_list"], new_precinct 
      end
    end
  
#
# Find or create the districts.
#<tt>yaml_districts</tt>::district_list from yaml input
#<tt>precinct</tt>::Precinct object that includes those districts
#
    def load_districts yaml_districts, precinct
      if yaml_districts.nil?
        puts "*** invalid Precinct on Yaml Import:"
        pp yaml_prec 
        raise "YAML error: invalid precinct. See console for details"
      end
      yaml_districts.each do |yaml_dist|
        dist_disp_name = yaml_dist["display_name"]
        new_district = District.find_by_display_name(dist_disp_name)
        if !new_district
          new_district = District.create(:display_name => dist_disp_name, :district_type_id => 1)
        end
#
# Add this district to the district set being built, and to the precinct being built
#
        @dist_set.districts << new_district
        new_district.precincts << precinct
#
# For later linking, record which district "ident" got which District object
#
        @dist_id_map[yaml_dist["ident"]] = new_district
      end
    end # def load_districts
  end # class
end # module
