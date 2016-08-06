class Web::TasksController < Web::ApplicationController
  before_action :authenticate_user
  before_action :protect_restricted_form_params, only: [:create, :update]
  before_action :load_resource, only: [:edit, :update, :show, :destroy, :start, :finish, :reactivate, :assign_to]
  before_action :on_resource_not_found, only: [:edit, :update, :show, :destroy]

  def index
    tasks = Task.order(:id)
    tasks = tasks.where(user_id: current_user.id) if current_user.user?

    @tasks = tasks.all
  end

  def new
    @task = Task.new user_id: user_id_for_task
  end

  def create
    @task = Task.new(resource_params)

    if @task.save
      redirect_to tasks_path, notice: t(:resource_created, scope: 'task.messages')
    else
      flash.now.alert = t(:resource_data_has_errors, scope: 'task.messages')
      render :new
    end
  end

  def edit
  end

  def update

    if @task.update_attributes(resource_params)
      redirect_to tasks_path, notice: t(:resource_updated, scope: 'task.messages')
    else
      flash.now.alert = t(:resource_data_has_errors, scope: 'task.messages')
      render :edit
    end
  end

  def show
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: t(:resource_removed, scope: 'task.messages')
  end

  def start
    if request.post?
      render(json: {status: "ERROR", reason: t(:resource_not_found, scope: 'task.messages')}) and return if @task.blank?
      if @task.start
        render json: {status: "OK", started_at: @task.started_at}
      else
        render json: {status: "ERROR", reason: @task.errors.full_messages.try(:first)}
      end
    else
      if @task.start
        redirect_to tasks_path, notice: t(:resource_updated, scope: 'task.messages')
      else
        redirect_to tasks_path, alert: t(:resource_data_has_errors, scope: 'task.messages')
      end
    end
  end

  def finish
    if request.post?
      render(json: {status: "ERROR", reason: t(:resource_not_found, scope: 'task.messages')}) and return if @task.blank?
      if @task.finish
        render json: {status: "OK", finished_at: @task.finished_at}
      else
        render json: {status: "ERROR", reason: @task.errors.full_messages.try(:first)}
      end
    else
      if @task.finish
        redirect_to tasks_path, notice: t(:resource_updated, scope: 'task.messages')
      else
        redirect_to tasks_path, alert: t(:resource_data_has_errors, scope: 'task.messages')
      end
    end
  end

  def reactivate
    if @task.reactivate
      redirect_to tasks_path, notice: t(:resource_updated, scope: 'task.messages')
    else
      redirect_to tasks_path, alert: t(:resource_data_has_errors, scope: 'task.messages')
    end
  end

  def assign_to
    render(json: {status: 'ERROR', reason: t(:permission_denied)}) and return unless current_user.admin?
    render(json: {status: "ERROR", reason: t(:resource_not_found, scope: 'task.messages')}) and return if @task.blank?
    render(json: {status: "ERROR", reason: t(:resource_not_found, scope: 'user.messages')}) and return unless User.exists?(params[:user_id])
    @task.user_id = params[:user_id]
    if @task.save
      render json: {status: "OK"}
    else
      render json: {status: "ERROR", reason: @task.errors.full_messages.join(";")}
    end
  end

  private
    def resource_params
      params.require(:task).permit(:name, :description, :user_id, :attachment, :attachment_cache, :remote_attachment_url)
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
      redirect_to tasks_path, alert: t(:resource_not_found, scope: 'task.messages') unless @task.present?
    end
end
