require 'test_helper'

class BallotVARuleTest < ActiveSupport::TestCase
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

      party = Party.find_by_display_name("IndependentGreen")
      assert_equal 1, @va_klass.party_order[party]

      party = Party.find_by_display_name("Democratic")
      assert_equal 2, @va_klass.party_order[party]

      party = Party.find_by_display_name("Republican")
      assert_equal 3, @va_klass.party_order[party]

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
        assert_equal "cand_Independent", sorted_candidates[0].display_name
        assert_equal "cand_IndependentGreen", sorted_candidates[1].display_name
        assert_equal "cand_Democratic", sorted_candidates[2].display_name
        assert_equal "cand_Republican", sorted_candidates[3].display_name
      end
      
    end # end context
  end # end context
end
