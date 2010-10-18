require 'test_helper'

class PartiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:parties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create party" do
    assert_difference('Party.count') do
      post :create, :party => {:display_name => "Democrat" }
    end

    assert_redirected_to party_path(assigns(:party))
  end

end
