require "test_helper"

class LessonCompletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
    @lesson = lessons(:one)
    @student = users(:two)
  end

  test "should create completion when enrolled" do
    sign_in @student
    @course.enrollments.create!(user: @student, price_paid_cents: 0)
    assert_difference("LessonCompletion.count") do
      post course_lesson_lesson_completions_url(@course, @lesson)
    end
    assert_redirected_to course_lesson_url(@course, @lesson)
  end
end
