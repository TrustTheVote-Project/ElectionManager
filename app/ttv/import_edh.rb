require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class ImportEDH
    attr_reader :hash, :election

    # <tt>hash::</tt> Hash containing ElectionManager data. Has been processed for errors.
    def initialize(hash)
      @hash = hash
      @jurisdictions = []
    end
    
    def import
      @hash["body"]["jurisdictions"].each { |juris| load_jurisdiction juris }
      @hash["body"]["districts"].each { |dist| load_district dist}
      @hash["body"]["precincts"].each { |prec| load_precinct prec}
      @hash["body"]["candidates"].each { |cand| load_candidate cand}
      @hash["body"]["contests"].each { |cont| load_contest cont}
      @hash["body"]["elections"].each { |elec| load_election elec}
    end
    
    def load_jurisdiction jurisdiction
      new_jurisdiction = DistrictSet.find_or_create_by_ident(:display_name => jurisdiction["display_name"], :ident => jurisdiction["ident"])
    end
    
    def load_district district
      new_district = District.find_or_create_by_ident(:display_name => district["display_name"], :ident => district["ident"], :type => DistrictType.find_or_create_by_title(district["type"]))
      new_district.district_sets << DistrictSet.find_by_ident(district["jurisdiction_identref"])
    end

    def load_precinct precinct
      new_precinct = Precinct.find_or_create_by_ident(:display_name => precinct["display_name"], :ident => precinct["ident"])
      precinct["districts"].each{|dist| new_precinct.districts << District.find_by_ident(dist["identref"])} if precinct["districts"]
      new_precinct.save!
    end
    
    def load_candidate candidate
      new_candidate = Candidate.find_or_create_by_ident(:display_name => candidate["display_name"], :ident => candidate["ident"], :party => Party.find_or_create_by_display_name(candidate["party"]))
    end

    def load_contest contest
      new_contest = Contest.find_or_create_by_ident(:display_name => contest["display_name"], :ident => contest["ident"], :district => District.find_by_ident(contest["district_identref"]))
      contest["candidates"].each{ |cand| new_contest.candidates << Candidate.find_by_ident(cand["identref"])} if contest["candidates"]
      # TODO: Throws validation errors:
      # new_contest.save!
    end

    def load_election election
      new_election = Election.find_or_create_by_ident(:display_name => election["display_name"], :ident => election["ident"])
      # TODO: Throws validation errors:
      # election["contests"].each{ |cont| new_election.contests << Contest.find_by_ident(cont["identref"])} if election["contests"]
      # new_election.save!
    end
    
  end
end