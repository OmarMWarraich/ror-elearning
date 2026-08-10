require "application_system_test_case"

class HealthCheckTest < ApplicationSystemTestCase
  test "health check returns success" do
    visit rails_health_check_url
    assert_text "success"
  end
end
