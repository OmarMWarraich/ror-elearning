class CoursesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show search]
  before_action :set_course, only: %i[show edit update destroy]
  before_action :authorize_course, only: %i[index new create search]

  def index
    @courses = Course.accessible_by(current_ability).recent
  end

  def show
    authorize! :read, @course
    @lessons = @course.lessons.accessible_by(current_ability).ordered
    @reviews = @course.reviews.order(created_at: :desc).limit(10)
    @review = @course.reviews.new if user_signed_in? && can?(:create, Review.new(user: current_user, course: @course))
  end

  def new
    @course = Course.new
    @course.instructor = current_user
    authorize! :create, @course
  end

  def edit
    authorize! :update, @course
  end

  def create
    @course = Course.new(course_params)
    @course.instructor ||= current_user
    authorize! :create, @course

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @course.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    authorize! :update, @course

    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: "Course was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @course.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    authorize! :destroy, @course
    @course.destroy!

    respond_to do |format|
      format.html { redirect_to courses_path, notice: "Course was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def search
    @courses = Course.accessible_by(current_ability)
                     .where("lower(title) LIKE ?", "%#{params[:q].to_s.downcase}%")
  end

  private

  def set_course
    @course = Course.find(params.expect(:id))
  end

  def authorize_course
    authorize! params[:action].to_sym, Course
  end

  def course_params
    params.expect(course: %i[title description status instructor_id category_id price_cents duration_in_minutes published_at])
  end
end
