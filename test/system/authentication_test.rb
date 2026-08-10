require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "signing in with email and password" do
    visit new_user_session_url
    fill_in "Email or Username", with: @user.email
    fill_in "Password", with: "password"
    click_on "Log in"
    assert_text "Signed in successfully."
    assert_current_path dashboard_path
  end

  test "signing in with username and password" do
    visit new_user_session_url
    fill_in "Email or Username", with: @user.username
    fill_in "Password", with: "password"
    click_on "Log in"
    assert_text "Signed in successfully."
  end

  test "signing out" do
    sign_in @user
    visit root_url
    click_on "Sign out"
    assert_text "Signed out successfully."
  end
end
