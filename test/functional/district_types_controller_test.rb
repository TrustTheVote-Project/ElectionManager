require 'test_helper'

class DistrictTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:district_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end
