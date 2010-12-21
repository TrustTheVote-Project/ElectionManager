# OSDV Election Manager - Shoulda Macros to create sample datamodel data
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require "test/unit"
#
# Macros to create various structured Precincts, PrecinctSplits, DistrictSets and Districts
#
class Test::Unit::TestCase
  
# Setup a Precinct
# <tt>name:</tt>  Name of the Precinct
# <tt>count:</tt> Number of PrecinctSplits in this precinct. Each split has a pre-ordained number of Districts. Default = 1. 0<Count<=4
# <tt>juris:</tt> Jurisdiction that should own all of the generated bits. Default nil, meaning they are 'dangling'
  def setup_precinct name, count=1, juris=nil
    district_counts = [3, 4, 3, 2, 3]
    assert count <= district_counts.length
    @prec_new = Precinct.create :display_name => name
    @prec_new.jurisdiction = juris unless juris.nil?
    last_genned_dist = 0
    (0..count-1).each do |i|
      setup_precinct_split("#{name} Split #{i}", last_genned_dist, last_genned_dist + district_counts[i])
      last_genned_dist += district_counts[i]
      @prec_new.precinct_splits << @prec_split_new
    end
    @prec_new.save
    @prec_new
  end

# TODO: why set up @district_set_new
# Setup a PrecinctSplit
# <tt>name:</tt>name to give it
# <tt>from, to:</tt>District number in name of Districts created. Also implies how many Ditricts to create
# <tt>juris:</tt> Jurisdiction that should own all of the generated bits. Default nil, meaning they are 'dangling' 
  def setup_precinct_split name, from, to, juris=nil
    setup_districtset name, from, to, juris
    @prec_split_new = PrecinctSplit.create! :display_name => name
    @prec_split_new.district_set = @district_set_new
    @prec_split_new.save
    @prec_split_new
  end

# TODO: why set up @district_set_new
# Setup a DistrictSet
#<tt>name:</tt>Name for it
# <tt>from, to:</tt>District number in name of Districts created. Also implies how many Ditricts to create
# <tt>juris:</tt> Jurisdiction that should own all of the generated bits. Default nil, meaning they are 'dangling' 
  def setup_districtset name, from, to, juris=nil
    @district_set_new = DistrictSet.make(:display_name => name)
    (from..to-1).each do |i|
      new_district = District.create!(:display_name => "#{name} District #{i}", :district_type => DistrictType::COUNTY)
      new_district.jurisdiction = juris unless juris.nil?
      @district_set_new.districts << new_district
      assert @district_set_new.valid?
    end
    @district_set_new.save
    @district_set_new
  end
  
# Set up a jurisdiction with a single precinct. NB a different way of returning the
# results. I am trying this to see if it's more useful.
  def setup_jurisdiction name
    precinct = setup_precinct(:display_name => "Prec for #{name}")
    precinct.jurisdiction = jurisdiction
    precinct.save
    {:jurisdiction => jurisdiction, :precinct => precinct}
  end

  
# Set up info for a test election:
# @election = :display_name => "reiciendis", :district_set_id => 1
# @ds1 = :display_name => "DistrictSet 1"
# @ds2 = :display_name => "DistrictSet 2"
# @split1 = :display_name => "Precinct Split 1",
# @split2 = :display_name => "Precinct Split 2"

  def setup_test_election
    # create 3 districts
    d1 = District.make(:display_name => "District 1", :district_type => DistrictType::COUNTY )
    d2 = District.make(:display_name => "District 2", :district_type => DistrictType::COUNTY )
    d3 = District.make(:display_name => "District 3", :district_type => DistrictType::COUNTY )
    d1.save!
    d2.save!
    d3.save!

    # create a district set that will have district 1 and 2
    @ds1 = DistrictSet.make(:display_name => "DistrictSet 1")
    @ds1.districts << d1
    @ds1.districts << d2
    @ds1.save!
    
    
    @ds2 = DistrictSet.make(:display_name => "DistrictSet 2")
    @ds2.districts << d3
    @ds2.save!

    # create a precinct_split that has district_set 1
    @split1 = PrecinctSplit.make(:display_name => 'Precinct Split 1')
    @split1.district_set = @ds1
    @split1.save!
    # create a precinct_split that has district_set 1
    @split2 = PrecinctSplit.make(:display_name => 'Precinct Split 2')
    @split2.district_set = @ds1
    @split2.save!
    
    # add these precinct split to a precinct
    @precinct = Precinct.make(:display_name => 'Precinct 1')
    @precinct.jurisdiction =  @ds1
    @precinct.precinct_splits << @split1
    @precinct.precinct_splits << @split2
    @precinct.save!
    
    # create a contest that is for district 1 
    c1 = Contest.make(:display_name => "Contest 1")
    c1.district = d1
    c1.save!
    
    # create a contest that is for district 3
    c2 = Contest.make(:display_name => "Contest 2")
    c2.district = d3
    c2.save!
    
    # create questions and attach them to districts
    q1 = Question.make(:display_name => "Question 1")
    q2 = Question.make(:display_name => "Question 2")
    q3 = Question.make(:display_name => "Question 3")
    q1.requesting_district = d1
    q2.requesting_district = d2
    q3.requesting_district = d3
    
    
    # create an election that has this contest
    @election = Election.make
    @election.contests << c1
    @election.questions << q1
    @election.questions << q2
    @election.district_set = @ds1
    @election.save!
  end
  
  
    def create_question(name, district, election, text)
    question = Question.make(:display_name => name,
                                 :election => election,
                                 :requesting_district => district,
                                 :question => text)
  
  end
  
  def create_contest(name, voting_method, district, election, position = 0)
    contest = Contest.make(:display_name => name,
                           :voting_method => voting_method,
                           :district => district,
                           :election => election,
                           :position => position,
                           :ident => "ident-#{name}")
    
    position += 1
    [:democrat, :republican, :independent].each do |party_sym|
      party = Party.make(party_sym)
      Candidate.make(:party => party, :display_name => "#{name}_#{party_sym.to_s[0..2]}", :contest => contest, :ident => "ident-#{name}_#{party_sym.to_s[0..2]}_#{contest.display_name}")
    end
    contest
  end


end
