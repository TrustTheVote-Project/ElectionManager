# OSDV Election Manager - Unit Test
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
require File.dirname(__FILE__) + '/../test_helper'

class BallotVARuleTest < ActiveSupport::TestCase
  context "Candidate party display" do
    setup do
      create_ballot_config(true)
      @template.ballot_rule_classname = "VA"
    end
    
    should "show party for districts that are state or federal" do
      district = District.make(:display_name => "District 1", :district_type => DistrictType::CONGRESSIONAL)
      contest = create_contest("Contest1", VotingMethod::WINNER_TAKE_ALL, district, @election)
      assert @template.contest_include_party(contest)
    end

    should "not show party for districts that are not state or federal" do
      district = District.make(:display_name => "District 1", :district_type => DistrictType::DISTRICT)
      contest = create_contest("Contest1", VotingMethod::WINNER_TAKE_ALL, district, @election)
      assert !@template.contest_include_party(contest)
    end
  end
  
  context "Candidate sorting strategy" do
    setup do
      @base_klass = ::TTV::BallotRule::Base
      @va_klass = @base_klass.find_subclass("VA")
    end
    
    should 'have all the VA parties' do
      %w{ Republican Democratic Independent IndependentGreen}.each do |p_name|
        party = Party.find_by_display_name(p_name)
        assert party, "Party #{p_name} not found"
        assert @va_klass.party_order[party]
      end
    end

    should 'have all the correct VA party ordering' do
      party = Party.find_by_display_name("Independent")
      assert_equal 0, @va_klass.party_order[party]

      party = Party.find_by_display_name("Libertarian")
      assert_equal 1, @va_klass.party_order[party]
      
      party = Party.find_by_display_name("IndependentGreen")
      assert_equal 2, @va_klass.party_order[party]

      party = Party.find_by_display_name("Democratic")
      assert_equal 3, @va_klass.party_order[party]
      
      party = Party.find_by_display_name("Democrat")
      assert_equal 3, @va_klass.party_order[party]

      party = Party.find_by_display_name("Republican")
      assert_equal 4, @va_klass.party_order[party]

    end

    context "condidate ordering " do
      setup do
        @va_strategy = @base_klass.create_instance("VA")
        
        district = District.make
        election = Election.make
        @candidates = []
        %w{ Republican Democratic Independent IndependentGreen}.each do |p_name|
          party = Party.find_by_display_name(p_name)
          @candidates << Candidate.make(:display_name => "cand_#{party.display_name}", :party => party)
        end
      end
      
      should "have the correct ordering" do
        sorted_candidates = @candidates.sort(&@va_strategy.candidate_ordering)
        assert_equal "cand_Independent", sorted_candidates[3].display_name
        assert_equal "cand_IndependentGreen", sorted_candidates[2].display_name
        assert_equal "cand_Democratic", sorted_candidates[1].display_name
        assert_equal "cand_Republican", sorted_candidates[0].display_name
      end
      
    end # end context
  end # end context
end
