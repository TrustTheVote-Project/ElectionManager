require 'test_helper'

class CandidateTest < ActiveSupport::TestCase
  context "basic test" do
    should "able to create new candidate" do
      prec = Candidate.new(:display_name => "i am new")
      prec.save!
   end
  end
end
