class Web::UsersController < Web::ApplicationController
  before_action :authenticate_user
  before_action :check_admin_permissions, only: [:index, :new, :create, :destroy]
  before_action :check_admin_or_self_permissions, only: [:edit, :update, :show]
  before_action :load_resource, only: [:edit, :update, :show, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(resource_params)

    if @user.save
      redirect_to users_path, notice: t(:resource_created, scope: 'user.messages')
    else
      flash.now.alert = t(:resource_data_has_errors, scope: 'user.messages')
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(resource_params)
      redirect_to resolve_redirect_path, notice: t(:resource_updated, scope: 'user.messages')
    else
      flash.now.alert = t(:resource_data_has_errors, scope: 'user.messages')
      render :edit
    end
  end

  def show
  end

  def destroy
    redirect_to users_path, alert: t(:admin_selfdestruction_error, scope: 'user.messages') and return if current_user.admin? && current_user.id == params[:id].to_i
    @user.destroy
    redirect_to resolve_redirect_path, notice: t(:resource_removed, scope: 'user.messages')
  end

  private
    def check_admin_permissions
      redirect_to user_path(current_user), alert: t(:permission_denied) unless current_user.admin?
    end

    def check_admin_or_self_permissions
      redirect_to user_path(current_user), alert: t(:permission_denied) unless current_user.admin? || current_user.id == params[:id].try(:to_i)
    end

    def resource_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end

    def load_resource
      @user = User.where(id: params[:id]).first

      redirect_to resolve_redirect_path, alert: t(:resource_not_found, scope: 'user.messages') if @user.blank?
    end

    def resolve_redirect_path
      current_user.admin? ? users_path : user_path(current_user)
    end
end
