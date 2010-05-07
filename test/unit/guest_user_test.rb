require 'test_helper'
=begin
class GuestUserTest < ActiveSupport::TestCase
  context "Guest User" do
    
    setup do
      role = UserRole.new(:name => "public")
      role.user =  User.new(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")
      role.save

      @ability = Ability.new(User.first)
    end

    subject { User.last }
    should_have_many :roles

    should "have a public role " do
      assert subject.role? 'public'
      assert subject.role? :public
    end
    
    %w{ Candidate Contest District DistrictSet DistrictType Election Precinct Question User UserRole UserSession VotingMethod}.each do |model|
      

      should "not be allowed to create a #{model}" do
        assert @ability.cannot?(:create, model)
      end

      should "not be allowed to edit a #{model}" do
        assert @ability.cannot?(:edit, model)
      end

      should "be allowed to read a #{model}" do
        assert @ability.can?(:read, model)
      end

      should "not be allowed to destroy a #{model}" do
        assert @ability.cannot?(:destroy, model)
      end
    end #
    
    should "not allowed to create a YAMLExport model" do
      assert @ability.cannot?(:create, TTV::YAMLExport)
    end

    should "not allowed to create a YAMLImport model" do
      assert @ability.cannot?(:create, TTV::YAMLImport)
    end
    
  end
    
end
=end
