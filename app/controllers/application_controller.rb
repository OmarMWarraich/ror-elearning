class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  helper_method :current_enrollment

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email username first_name last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email username first_name last_name bio])
  end

  def current_enrollment
    return unless user_signed_in? && @course

    @current_enrollment ||= @course.enrollments.active.find_by(user: current_user)
  end
end
