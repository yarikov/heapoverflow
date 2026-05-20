# frozen_string_literal: true

require 'application_responder'

class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include Pagy::Method

  self.responder = ApplicationResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionPolicy::Unauthorized do |exception|
    render json: { error: exception.message }, status: :unauthorized
  end

  protected

  DEVISEPARAMS = %i[full_name email password password_confirmation].freeze

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(DEVISEPARAMS) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(DEVISEPARAMS) }
  end
end
