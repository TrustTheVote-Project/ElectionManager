require 'test_helper'

class UserContextTest < ActiveSupport::TestCase
  
  context "basic UserContext" do
    setup do
      dummy_session = { }
      @uc = UserContext.new(dummy_session)
    end
    should "successfully be created" do
      assert_not_nil @uc
    end
    
    should "not have any context yet" do
      assert !@uc.election? && !@uc.jurisdiction
    end
    
    context "with a basic jurisdiction" do
      setup do
        @jur = DistrictSet.make
        @uc.jurisdiction = @jur
      end
      
      should "locate primary name" do
        assert_equal @jur.display_name, @uc.jurisdiction_name
      end
      
      should "locate secondary name" do
        assert_equal @jur.secondary_name, @uc.jurisdiction_secondary_name
      end
    end
    
    context "Re-created UserContext" do
      setup do
        @sess = {}
        @uc = UserContext.new(@sess)
        @jur = DistrictSet.make
        @elect = Election.make
        @cont = Contest.make
        @question = Question.make
        @prec = Precinct.make
      end
      
      should "know which was the current jurisdiction" do
        @uc.jurisdiction = @jur
        @other_uc = UserContext.new(@sess)
        assert @jur, @other_uc.jurisdiction
      end
      
      should "know that there was a current jurisdiction" do
        @uc.jurisdiction = @jur
        @other_uc = UserContext.new(@sess)
        assert @other_uc.jurisdiction?
      end

      should "know that there was a current election" do
        @uc.election = @elect
        @other_uc = UserContext.new(@sess)
        assert @other_uc.election?
      end
      
      should "know that there was a current question" do
        @uc.question = @question 
        @other_uc = UserContext.new(@sess)
        assert @other_uc.question?
      end

      should "know that there was a current contest" do
        @uc.contest = @cont
        @other_uc = UserContext.new(@sess)
        assert @other_uc.contest?
      end
      
     should "know that there was a current precinct" do
        @uc.precinct = @prec
        @other_uc = UserContext.new(@sess)
        assert @other_uc.precinct?
      end
    end
  end   
  
end
