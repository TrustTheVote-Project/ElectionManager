require 'test_helper'

class MediaControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create medium" do
    assert_difference('Medium.count') do
      post :create, :medium => { }
    end

    assert_redirected_to medium_path(assigns(:medium))
  end

  test "should show medium" do
    get :show, :id => media(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => media(:one).to_param
    assert_response :success
  end

  test "should update medium" do
    put :update, :id => media(:one).to_param, :medium => { }
    assert_redirected_to medium_path(assigns(:medium))
  end

  test "should destroy medium" do
    assert_difference('Medium.count', -1) do
      delete :destroy, :id => media(:one).to_param
    end

    assert_redirected_to media_path
  end
end
