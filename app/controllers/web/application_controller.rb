class Web::ApplicationController < ApplicationController
  helper_method :current_user

  def authenticate_user
    unless current_user
      redirect_to new_session_path
    end
  end

  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end
end
