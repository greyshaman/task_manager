class Web::TasksController < Web::ApplicationController
  before_action :authenticate_user
  before_action :protect_restricted_form_params, only: [:create, :update]
  before_action :load_resource, only: [:edit, :update, :show, :destroy, :start, :finish, :assign_to]
  before_action :on_resource_not_found, only: [:edit, :update, :show, :destroy]

  def index
    scope = Task.all
    scope = scope.where(user_id: current_user.id) if current_user.user?

    @tasks = scope.all
  end

  def new
    @task = Task.new user_id: user_id_for_task
  end

  def create
    @task = Task.new(resource_params)

    if @task.save
      redirect_to tasks_path, notice: "Task has been created successfuly!"
    else
      flash.now.alert = "Task data contains errors!"
      render :new
    end
  end

  def edit
  end

  def update
    @task.assign_attributes(resource_params)

    if @task.save
      redirect_to tasks_path, notice: "Task has been updated successfuly!"
    else
      flash.now.alert = "Task data contains errors!"
      render :edit
    end
  end

  def show
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task has been removed!"
  end

  def start
    render(json: {status: "ERROR", reason: "Task not found"}) and return if @task.blank?
    if @task.start
      render json: {status: "OK", started_at: @task.started_at}
    else
      render json: {status: "ERROR", reason: @task.errors.full_messages.try(:first)}
    end
  rescue => e
    render json: {status: "ERROR", reason: e.message}
  end

  def finish
    render(json: {status: "ERROR", reason: "Task not found"}) and return if @task.blank?
    if @task.finish
      render json: {status: "OK", finished_at: @task.finished_at}
    else
      render json: {status: "ERROR", reason: @task.errors.full_messages.try(:first)}
    end
  rescue => e
    render json: {status: "ERROR", reason: e.message}
  end

  def assign_to
    render(json: {status: 'ERROR', reason: 'Permission denied'}) and return unless current_user.admin?
    render(json: {status: "ERROR", reason: "Task not found"}) and return if @task.blank?
    render(json: {status: "ERROR", reason: "User not found"}) and return unless User.exists?(params[:user_id])
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
      redirect_to tasks_path, alert: "Task not found!" unless @task.present?
    end
end
