require 'test_helper'

class BallotStylesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ballot_styles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
end
