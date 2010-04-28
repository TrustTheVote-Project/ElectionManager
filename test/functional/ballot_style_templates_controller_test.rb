require 'test_helper'

class BallotStyleTemplatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ballot_style_templates)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

 end
