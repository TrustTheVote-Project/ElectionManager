require 'test_helper'

class VotingMethodsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:voting_methods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end
