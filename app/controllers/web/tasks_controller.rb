class Web::TasksController < Web::ApplicationController
  RESOURCE_NOT_FOUND       = "Task not found!"
  RESOURCE_CREATED         = "Task has been created successfuly!"
  RESOURCE_UPDATED         = "Task has been updated successfuly!"
  RESOURCE_DATA_HAS_ERRORS = "Task data contains errors!"
  PERMISSION_DENIED        = "Permission denied!"
  RESOURCE_REMOVED         = "Task has been removed!"

  before_action :authenticate_user
  before_action :protect_restricted_form_params, only: [:create, :update]
  before_action :load_resource, only: [:edit, :update, :show, :destroy, :start, :finish, :reactivate, :assign_to]
  before_action :on_resource_not_found, only: [:edit, :update, :show, :destroy]

  def index
    scope = Task.order(:id)
    scope = scope.where(user_id: current_user.id) if current_user.user?

    @tasks = scope.all
  end

  def new
    @task = Task.new user_id: user_id_for_task
  end

  def create
    @task = Task.new(resource_params)

    if @task.save
      redirect_to tasks_path, notice: RESOURCE_CREATED
    else
      flash.now.alert = RESOURCE_DATA_HAS_ERRORS
      render :new
    end
  end

  def edit
  end

  def update
    @task.assign_attributes(resource_params)

    if @task.save
      redirect_to tasks_path, notice: RESOURCE_UPDATED
    else
      flash.now.alert = RESOURCE_DATA_HAS_ERRORS
      render :edit
    end
  end

  def show
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: RESOURCE_REMOVED
  end

  def start
    if request.post?
      render(json: {status: "ERROR", reason: RESOURCE_NOT_FOUND}) and return if @task.blank?
      if @task.start
        render json: {status: "OK", started_at: @task.started_at}
      else
        render json: {status: "ERROR", reason: @task.errors.full_messages.try(:first)}
      end
    else
      if @task.start
        redirect_to tasks_path, notice: RESOURCE_UPDATED
      else
        redirect_to tasks_path, alert: RESOURCE_DATA_HAS_ERRORS
      end
    end
  end

  def finish
    if request.post?
      render(json: {status: "ERROR", reason: RESOURCE_NOT_FOUND}) and return if @task.blank?
      if @task.finish
        render json: {status: "OK", finished_at: @task.finished_at}
      else
        render json: {status: "ERROR", reason: @task.errors.full_messages.try(:first)}
      end
    else
      if @task.finish
        redirect_to tasks_path, notice: RESOURCE_UPDATED
      else
        redirect_to tasks_path, alert: RESOURCE_DATA_HAS_ERRORS
      end
    end
  end

  def reactivate
    if @task.reactivate
      redirect_to tasks_path, notice: RESOURCE_UPDATED
    else
      redirect_to tasks_path, alert: RESOURCE_DATA_HAS_ERRORS
    end
  end

  def assign_to
    render(json: {status: 'ERROR', reason: PERMISSION_DENIED}) and return unless current_user.admin?
    render(json: {status: "ERROR", reason: RESOURCE_NOT_FOUND}) and return if @task.blank?
    render(json: {status: "ERROR", reason: Web::UsersController::RESOURCE_NOT_FOUND}) and return unless User.exists?(params[:user_id])
    @task.user_id = params[:user_id]
    if @task.save
      render json: {status: "OK"}
    else
      render json: {status: "ERROR", reason: @task.errors.full_messages.join(";")}
    end
  end

  private
    def resource_params
      params.require(:task).permit(:name, :description, :user_id)
    end

    def user_id_for_task(user_id_from_param = params[:user_id])
      if current_user.admin?
        user_id_from_param || current_user.id
      else
        current_user.id
      end
    end

    def protect_restricted_form_params
      params[:task].merge!("user_id" => user_id_for_task(params[:task][:user_id])) if params[:task][:user_id].present?
    end

    def load_resource
      @task =
        if current_user.admin?
          Task.where(id: params[:id]).first
        else
          current_user.tasks.where(id: params[:id]).first
        end
    end

    def on_resource_not_found
      redirect_to tasks_path, alert: RESOURCE_NOT_FOUND unless @task.present?
    end
end
