require 'test_helper'

class BallotLayoutStrategyTest < ActiveSupport::TestCase
  class ::TTV::BallotLayoutStrategy::Dummy < ::TTV::BallotLayoutStrategy::Base
  end
  
  context "Layout Inheritence" do
    setup do
      @va_klass = ::TTV::BallotLayoutStrategy::VA
      @dummy_klass = ::TTV::BallotLayoutStrategy::Dummy
    end
    
    should "get strategy subclasses" do
      assert  !::TTV::BallotLayoutStrategy::Base.strategies.empty?
      assert ::TTV::BallotLayoutStrategy::Base.strategies.include?(@va_klass)
      assert ::TTV::BallotLayoutStrategy::Base.strategies.include?(@dummy_klass)
    end
  end  # end context
  
  context "Class methods" do
    
    setup do
      @strategy_display_name = "VA Ballot Layout"
      @base_klass = ::TTV::BallotLayoutStrategy::Base
      @va_klass = ::TTV::BallotLayoutStrategy::VA
      @dummy_klass = ::TTV::BallotLayoutStrategy::Dummy
    end
    
    should "find a strategy class by name" do
      assert  @base_klass.find_class("VA")
      assert_equal @va_klass, @base_klass.find_class("VA")

      assert  @base_klass.find_class(@va_klass)
      assert_equal @va_klass, @base_klass.find_class(@va_klass)
      
      assert  @base_klass.find_class("Dummy")
      assert_equal @dummy_klass, @base_klass.find_class("Dummy")
      
      assert  @base_klass.find_class(@dummy_klass)
      assert_equal @dummy_klass, @base_klass.find_class(@dummy_klass)
    end

    should "raise an NameError when finding a strategy class with an invalid string" do
      assert_raise NameError do
        @base_klass.find_class("VAXX")
      end
    end
    
    should "create a strategy instance by string" do
      assert  @base_klass.create("VA")
      assert  @base_klass.create("VA").instance_of?(@va_klass)
    end

    should "raise an NameError when creating a strategy with an invalid string" do
      assert_raise NameError do
        assert  @base_klass.find_class("VAX")
      end
    end
    
    should "find strategy class by display_name" do
      assert_equal @va_klass, @base_klass.find_class_by_display_name(@strategy_display_name)
    end
    
    should "not find a strategy for an invalid strategy display name" do
      assert_raise NameError do
        @base_klass.find_class_by_display_name("K" << @strategy_display_name )
      end
    end
    
    should "create a strategy for a valid strategy display name" do
      assert @base_klass.create_by_display_name(@strategy_display_name).instance_of?(@va_klass)
    end
    
    should "not create a strategy for an invalid strategy display name" do
      assert_raise NameError do
        @base_klass.create_by_display_name("NotAName").instance_of?(@va_klass)
      end
    end

  end
end
