require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:languages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
end
