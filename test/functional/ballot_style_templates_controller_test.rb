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

  test "should create ballot_style_template" do
    assert_difference('BallotStyleTemplate.count') do
      post :create, :ballot_style_template => { }
    end

    assert_redirected_to ballot_style_template_path(assigns(:ballot_style_template))
  end

  test "should show ballot_style_template" do
    get :show, :id => ballot_style_templates(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ballot_style_templates(:one).to_param
    assert_response :success
  end

  test "should update ballot_style_template" do
    put :update, :id => ballot_style_templates(:one).to_param, :ballot_style_template => { }
    assert_redirected_to ballot_style_template_path(assigns(:ballot_style_template))
  end

  test "should destroy ballot_style_template" do
    assert_difference('BallotStyleTemplate.count', -1) do
      delete :destroy, :id => ballot_style_templates(:one).to_param
    end

    assert_redirected_to ballot_style_templates_path
  end
end
