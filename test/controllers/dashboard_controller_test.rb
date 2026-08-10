require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index when signed in" do
    sign_in @user
    get dashboard_url
    assert_response :success
  end

  test "should redirect when not signed in" do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end
end
