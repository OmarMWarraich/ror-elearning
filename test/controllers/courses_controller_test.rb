require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
    @instructor = users(:one)
  end

  test "should get index" do
    get courses_url
    assert_response :success
  end

  test "should get new when signed in" do
    sign_in @instructor
    get new_course_url
    assert_response :success
  end

  test "should create course when signed in" do
    sign_in @instructor
    assert_difference("Course.count") do
      post courses_url, params: { course: { title: "New Course", description: "A new course.", instructor_id: @instructor.id, price_cents: 0 } }
    end

    assert_redirected_to course_url(Course.last)
  end

  test "should show course" do
    get course_url(@course)
    assert_response :success
  end

  test "should get edit when signed in" do
    sign_in @instructor
    get edit_course_url(@course)
    assert_response :success
  end

  test "should update course when signed in" do
    sign_in @instructor
    patch course_url(@course), params: { course: { title: "Updated Course" } }
    assert_redirected_to course_url(@course)
  end

  test "should destroy course when signed in" do
    sign_in @instructor
    assert_difference("Course.count", -1) do
      delete course_url(@course)
    end

    assert_redirected_to courses_url
  end

  test "should redirect new when not signed in" do
    get new_course_url
    assert_redirected_to new_user_session_url
  end
end
