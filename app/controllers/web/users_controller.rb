class Web::UsersController < Web::ApplicationController
  RESOURCE_NOT_FOUND          = "User not found!"
  RESOURCE_CREATED            = "User has been created successfuly!"
  RESOURCE_UPDATED            = "User has been updated successfuly!"
  RESOURCE_DATA_HAS_ERRORS    = "User data contains errors!"
  PERMISSION_DENIED           = "Permission denied!"
  RESOURCE_REMOVED            = "User has been removed!"
  ADMIN_SELFDESTRUCTION_ERROR = "Admin cannot remove himself!"

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
      redirect_to users_path, notice: RESOURCE_CREATED
    else
      flash.now.alert = RESOURCE_DATA_HAS_ERRORS
      render :new
    end
  end

  def edit
  end

  def update
    @user.assign_attributes(resource_params)
    if @user.save
      redirect_to resolve_redirect_path, notice: RESOURCE_UPDATED
    else
      flash.now.alert = RESOURCE_DATA_HAS_ERRORS
      render :edit
    end
  end

  def show
  end

  def destroy
    redirect_to users_path, alert: ADMIN_SELFDESTRUCTION_ERROR and return if current_user.admin? && current_user.id == params[:id].to_i
    @user.destroy
    redirect_to resolve_redirect_path, notice: RESOURCE_REMOVED
  end

  private
    def check_admin_permissions
      redirect_to user_path(current_user), alert: PERMISSION_DENIED unless current_user.admin?
    end

    def check_admin_or_self_permissions
      redirect_to user_path(current_user), alert: PERMISSION_DENIED unless current_user.admin? || current_user.id == params[:id].try(:to_i)
    end

    def resource_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end

    def load_resource
      @user = User.where(id: params[:id]).first

      redirect_to resolve_redirect_path, alert: RESOURCE_NOT_FOUND if @user.blank?
    end

    def resolve_redirect_path
      current_user.admin? ? users_path : user_path(current_user)
    end
end
