require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }, status: :unauthorized
  end

  check_authorization unless: :devise_controller?

  protected

  DEVISEPARAMS = [:full_name, :email, :password, :password_confirmation]

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(DEVISEPARAMS) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(DEVISEPARAMS) }
  end
end
