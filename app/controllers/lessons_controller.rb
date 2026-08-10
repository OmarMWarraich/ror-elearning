class LessonsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_course, only: %i[index new create]
  before_action :set_lesson, only: %i[show edit update destroy]

  def index
    @lessons = @course.lessons.accessible_by(current_ability).ordered
  end

  def show
    authorize! :read, @lesson
    @course = @lesson.course
  end

  def new
    @lesson = @course.lessons.new
    authorize! :create, @lesson
  end

  def create
    @lesson = @course.lessons.new(lesson_params)
    authorize! :create, @lesson

    if @lesson.save
      redirect_to [@course, @lesson], notice: "Lesson was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize! :update, @lesson
  end

  def update
    authorize! :update, @lesson

    if @lesson.update(lesson_params)
      redirect_to [@lesson.course, @lesson], notice: "Lesson was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! :destroy, @lesson
    @lesson.destroy!
    redirect_to course_lessons_path(@lesson.course), notice: "Lesson was successfully destroyed.", status: :see_other
  end

  private

  def set_course
    @course = Course.find(params.expect(:course_id))
  end

  def set_lesson
    @lesson = Lesson.find(params.expect(:id))
  end

  def lesson_params
    params.expect(lesson: %i[title content status position duration_in_minutes])
  end
end
