class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @enrolled_courses = current_user.enrolled_courses.distinct
    @instructed_courses = current_user.instructed_courses if current_user.instructor? || current_user.admin?
    @recent_enrollments = Enrollment.accessible_by(current_ability).order(created_at: :desc).limit(10) if current_user.instructor? || current_user.admin?
  end
end
