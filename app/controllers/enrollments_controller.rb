class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: %i[index create]
  before_action :set_enrollment, only: %i[show destroy]

  def index
    authorize! :read, Enrollment
    @enrollments = @course.enrollments.accessible_by(current_ability).order(created_at: :desc)
  end

  def show
    authorize! :read, @enrollment
  end

  def create
    @enrollment = @course.enrollments.new(user: current_user, price_paid_cents: @course.price_cents)
    authorize! :create, @enrollment

    if @enrollment.save
      redirect_to @enrollment, notice: "You have successfully enrolled in #{@course.title}."
    else
      redirect_to @course, alert: @enrollment.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize! :destroy, @enrollment
    @enrollment.update!(status: :dropped)
    redirect_to @enrollment.course, notice: "Enrollment was dropped.", status: :see_other
  end

  private

  def set_course
    @course = Course.find(params.expect(:course_id))
  end

  def set_enrollment
    @enrollment = Enrollment.find(params.expect(:id))
  end
end
