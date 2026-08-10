require "application_system_test_case"

class EnrollmentsTest < ApplicationSystemTestCase
  setup do
    @course = courses(:one)
    @student = users(:two)
  end

  test "student enrolls in a course" do
    sign_in @student
    visit course_url(@course)
    click_on "Enroll now"
    assert_text "You have successfully enrolled"
  end
end
