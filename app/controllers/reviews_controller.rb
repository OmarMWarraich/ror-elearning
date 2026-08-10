class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]
  before_action :set_course, only: %i[index create]
  before_action :set_review, only: %i[edit update destroy]

  def index
    authorize! :read, Review
    @reviews = @course.reviews.accessible_by(current_ability).order(created_at: :desc)
  end

  def create
    @review = @course.reviews.new(review_params.merge(user: current_user))
    authorize! :create, @review

    if @review.save
      redirect_to @course, notice: "Review was successfully created."
    else
      redirect_to @course, alert: @review.errors.full_messages.to_sentence
    end
  end

  def edit
    authorize! :update, @review
  end

  def update
    authorize! :update, @review

    if @review.update(review_params)
      redirect_to @review.course, notice: "Review was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! :destroy, @review
    @review.destroy!
    redirect_to @review.course, notice: "Review was successfully destroyed.", status: :see_other
  end

  private

  def set_course
    @course = Course.find(params.expect(:course_id))
  end

  def set_review
    @review = Review.find(params.expect(:id))
  end

  def review_params
    params.expect(review: %i[rating comment])
  end
end
