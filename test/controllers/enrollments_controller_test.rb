require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
    @student = users(:two)
    @instructor = users(:one)
  end

  test "should create enrollment when signed in" do
    sign_in @student
    assert_difference("Enrollment.count") do
      post course_enrollments_url(@course)
    end
    assert_redirected_to enrollment_url(Enrollment.last)
  end

  test "should get index when instructor" do
    sign_in @instructor
    get course_enrollments_url(@course)
    assert_response :success
  end

  test "should drop enrollment" do
    sign_in @student
    post course_enrollments_url(@course)
    enrollment = Enrollment.last
    delete enrollment_url(enrollment)
    assert_redirected_to @course
    assert_equal "dropped", enrollment.reload.status
  end
end
