class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    # byebug
    redirect_to user_path(current_user), :alert => exception.message
  end

  def configure_permitted_parameters
  	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :firstname, :lastname, :password, :password_confirmation, :pesel, :address) }
    # devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password, :remember_me) }
    # devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :firstname, :lastname, :password, :password_confirmation) }
  end

end
