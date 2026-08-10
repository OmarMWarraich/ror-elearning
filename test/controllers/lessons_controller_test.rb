require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
    @lesson = lessons(:one)
    @instructor = users(:one)
    @student = users(:two)
  end

  test "should get index" do
    get course_lessons_url(@course)
    assert_response :success
  end

  test "should show published lesson" do
    get course_lesson_url(@course, @lesson)
    assert_response :success
  end

  test "should get new when instructor" do
    sign_in @instructor
    get new_course_lesson_url(@course)
    assert_response :success
  end

  test "should create lesson when instructor" do
    sign_in @instructor
    assert_difference("Lesson.count") do
      post course_lessons_url(@course), params: { lesson: { title: "New Lesson", status: :published, position: 2 } }
    end
    assert_redirected_to course_lesson_url(@course, Lesson.last)
  end

  test "should update lesson when instructor" do
    sign_in @instructor
    patch course_lesson_url(@course, @lesson), params: { lesson: { title: "Updated Lesson" } }
    assert_redirected_to course_lesson_url(@course, @lesson)
  end

  test "should destroy lesson when instructor" do
    sign_in @instructor
    assert_difference("Lesson.count", -1) do
      delete course_lesson_url(@course, @lesson)
    end
    assert_redirected_to course_lessons_url(@course)
  end
end
