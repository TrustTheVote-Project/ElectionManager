require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class YAMLImport
    attr_reader :yml_election, :election, :dist_set
  
  # <tt>source::</tt> File object for file containing yaml text
    def initialize(source)
      @source = source
    end
  
  # Do the whole import process. Main entry point.
    def import
      @dist_id_map = {}
      @prec_id_map = {}
      @yml_election = YAML.load(@source)
      ActiveRecord::Base.transaction do
        @dist_set = DistrictSet.create(:display_name => @yml_election["jurisdiction_display_name"])
        @election = Election.create(:display_name => @yml_election["display_name"])
        @election.start_date = DateTime.now
        @election.district_set = @dist_set
        @election.save
        @yml_election["precinct_list"].each {|prec| load_precinct prec}
        @yml_election["contest_list"].each { |yml_contest| load_contest(yml_contest)}
      end
      @election
    end
    
  # load another contest into Election object
  # <tt>contest::</tt>Hash contains single contest from yaml
    def load_contest yml_cont
      dist = @dist_id_map[yml_cont["district_ident"]]
      new_contest = Contest.create(:display_name =>yml_cont["display_name"],
                                   :open_seat_count => 1)
      yml_cont["candidates"].each { |yml_cand| load_candidate yml_cand, new_contest }
      @election.contests << new_contest
      dist.contests << new_contest
     end
    
  # load another candiate
  # <tt>cand::</tt>Hash containing a single candidate from yaml
    def load_candidate cand, cont
      cand = Candidate.create(:display_name => cand["display_name"])
      cont.candidates << cand
    end
    
# load another precinct into Election object
# <tt>precinct::</tt>Hash contains a single precinct from yaml
    def load_precinct yaml_prec
#
# First find or create the precinct
#
      prec_disp_name = yaml_prec["display_name"]
      new_precinct = Precinct.find_by_display_name(prec_disp_name)
      if !new_precinct
        new_precinct = Precinct.create(:display_name => prec_disp_name)
      end
#
# Find or create the districts
#
      yaml_prec["district_list"].each do |yaml_dist|
        dist_disp_name = yaml_dist["display_name"]
        new_district = District.find_by_display_name(dist_disp_name)
        if !new_district
          new_district = District.create(:display_name => dist_disp_name, :district_type_id => 1)
        end
#
# Add this district to the district set being built, and to the precinct being built
#
        @dist_set.districts << new_district
        new_district.precincts << new_precinct
#
# For later linking, record which district "ident" got which District object
#
        @dist_id_map[yaml_dist["ident"]] = new_district
      end
#
# Record similarly which precinct "ident" got which precinct object
#
      @prec_id_map[yaml_prec["prec_id"]] = new_precinct
    end
  end
end
