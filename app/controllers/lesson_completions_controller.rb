class LessonCompletionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_lesson

  def create
    @enrollment = @course.enrollments.active.find_by!(user: current_user)
    @completion = @lesson.lesson_completions.new(user: current_user, enrollment: @enrollment)
    authorize! :create, @completion

    if @completion.save
      redirect_to [@course, @lesson], notice: "Lesson marked as complete."
    else
      redirect_to [@course, @lesson], alert: @completion.errors.full_messages.to_sentence
    end
  end

  private

  def set_course
    @course = Course.find(params.expect(:course_id))
  end

  def set_lesson
    @lesson = @course.lessons.find(params.expect(:lesson_id))
  end
end
