require 'custom_logger'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :authentication_error
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def not_found
    params[:controller] = 'errors'
    params[:action] = 'error-404'
    @error_code = 404
    render 'errors/base', status: 404
  end

  def access_denied(exception = nil)
    params[:controller] = 'errors'
    params[:action] = 'error-403'
    @error_code = 403
    render 'errors/base', status: 403
  end

  def authentication_error(exception = nil)
    params[:controller] = 'errors'
    params[:action] = 'error-401'
    @error_code = 401
    render 'errors/base', status: 401
  end

  def configure_devise_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  def after_sign_in_path_for(resource)
    begin
      # L params
      # L resource
      params[:redirect_to] ? URI(params[:redirect_to]).path : super
    rescue URI::InvalidURIError => e
      super
    end
  end
end
