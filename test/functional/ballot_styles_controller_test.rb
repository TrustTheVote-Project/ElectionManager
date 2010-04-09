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

  test "should create ballot_style" do
    assert_difference('BallotStyle.count') do
      post :create, :ballot_style => { }
    end

    assert_redirected_to ballot_style_path(assigns(:ballot_style))
  end

  test "should show ballot_style" do
    get :show, :id => ballot_styles(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ballot_styles(:one).to_param
    assert_response :success
  end

  test "should update ballot_style" do
    put :update, :id => ballot_styles(:one).to_param, :ballot_style => { }
    assert_redirected_to ballot_style_path(assigns(:ballot_style))
  end

  test "should destroy ballot_style" do
    assert_difference('BallotStyle.count', -1) do
      delete :destroy, :id => ballot_styles(:one).to_param
    end

    assert_redirected_to ballot_styles_path
  end
end
