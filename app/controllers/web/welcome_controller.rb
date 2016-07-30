class Web::WelcomeController < Web::ApplicationController
  before_action :authenticate_user

  def index
    redirect_to "/users/#{@current_user.id}/tasks"
  end
end
