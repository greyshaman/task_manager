class Web::WelcomeController < Web::ApplicationController
  before_action :authenticate_user

  def index
    redirect_to tasks_path
  end
end
