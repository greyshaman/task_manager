require 'rails_helper'

RSpec.describe Web::TasksController, type: :controller do
  let!(:admin) {FactoryGirl.create(:admin)}
  let!(:user_1) {FactoryGirl.create(:user)}
  let!(:user_2) {FactoryGirl.create(:user)}

  let!(:admin_tasks) {FactoryGirl.create_pair(:task, user: admin)}
  let!(:user_1_tasks) {FactoryGirl.create_pair(:task, user: user_1)}
  let!(:user_2_tasks) {FactoryGirl.create_pair(:task, user: user_2)}

  #index
  describe '#index' do
    context 'when not logged in user try access then' do
      before {get :index}

      it {expect(response).to redirect_to(new_session_path)}
    end

    # # index (admin)
    context "when admin access" do
      before do
        session[:user_id] = admin.id
        get :index
      end

      it {expect(response).to render_template(:index)}
      it {expect(assigns[:tasks].length).to eq(Task.count)}
    end

    # # index (user)
    context "when user access with correct user_id in request url" do
      before do
        session[:user_id] = user_1.id
        get :index
      end

      it {expect(response).to render_template(:index)}
      it {expect(assigns[:tasks].length).to eq(Task.where(user_id: user_1.id).count)}
    end
  end
  # new
  describe '#new' do
    context 'when not logged in user try access then' do
      before {get :new}

      it {expect(response).to redirect_to(new_session_path)}
    end

    # # new (admin with user_id)
     context "when admin access" do
      before do
        session[:user_id] = admin.id
        get :new
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(admin.id)}
    end

    context "when admin access with self id as user_id param" do
      before do
        session[:user_id] = admin.id
        get :new, user_id: admin.id
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(admin.id)}
    end

    context "when admin access with other user id as user_id param" do
      before do
        session[:user_id] = admin.id
        get :new, user_id: user_1.id
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
    end

    # # new (user) if wo user_id then task will be create for current_user
    context "when user access" do
      before do
        session[:user_id] = user_1.id
        get :new
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
    end

    context "when user access with self id as user_id param" do
      before do
        session[:user_id] = user_1.id
        get :new, user_id: user_1.id
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
    end

    # when user cheat his user_1 to another user id system will used current_user.id
    context "when user access with other user id as user_id param" do
      before do
        session[:user_id] = user_1.id
        get :new, user_id: user_2.id
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
    end
  end
  # create
  describe '#create' do
    context 'when not logged in user try access then' do
      before {post :create, task: FactoryGirl.attributes_for(:task, user_id: 1)}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context "when admin post new self task" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, task: FactoryGirl.attributes_for(:task, user_id: admin.id)}.to change{Task.count}.by(1)}
      end
      context do
        before {post :create, task: FactoryGirl.attributes_for(:task, user_id: admin.id)}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been created successfuly!")}
        it {expect(admin.tasks.last.user_id).to eq(admin.id)}
      end
    end

    context "when admin post new self task with empty name" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, task: FactoryGirl.attributes_for(:task, user_id: admin.id, name: "")}.to change{Task.count}.by(0)}
      end
      context do
        before {post :create, task: FactoryGirl.attributes_for(:task, user_id: admin.id, name: "")}

        it {expect(response).to render_template(:new)}
        it {expect(flash[:alert]).to eq("Task data contains errors!")}
        it {expect(assigns[:task]).to be_instance_of(Task)}
        it {expect(assigns[:task].user_id).to eq(admin.id)}
        it {expect(assigns[:task].errors.messages.length).to eq(1)}
      end
    end

    context "when admin post new task of other user" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, task: FactoryGirl.attributes_for(:task, user_id: user_1.id)}.to change{Task.count}.by(1)}
      end
      context do
        before {post :create, task: FactoryGirl.attributes_for(:task, user_id: user_1.id)}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been created successfuly!")}
        it {expect(user_1.tasks.last).to be_instance_of(Task)}
        it {expect(user_1.tasks.last.user_id).to eq(user_1.id)}
      end
    end

    context "when user post new self task" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {post :create, task: FactoryGirl.attributes_for(:task, user_id: user_1.id)}.to change{Task.count}.by(1)}
      end
      context do
        before {post :create, task: FactoryGirl.attributes_for(:task, user_id: user_1.id)}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been created successfuly!")}
        it {expect(user_1.tasks.last).to be_instance_of(Task)}
        it {expect(user_1.tasks.last.user_id).to eq(user_1.id)}
      end
    end

    context "when user post new task for other user" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {post :create, task: FactoryGirl.attributes_for(:task, user_id: user_2.id)}.to change{Task.count}.by(1)}
      end
      context do
        before {post :create, task: FactoryGirl.attributes_for(:task, user_id: user_2.id)}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been created successfuly!")}
        it {expect(user_1.tasks.last).to be_instance_of(Task)}
        it {expect(user_1.tasks.last.user_id).to eq(user_1.id)}
      end
    end
  end
  # edit
  describe '#edit' do
    context 'when not logged in user try access then' do
      before {get :edit, id: admin_tasks.first.id}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context "when admin edit self task" do
      before do
        session[:user_id] = admin.id
        get :edit, id: admin_tasks.first.id
      end

      it {expect(response).to render_template(:edit)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(admin.id)}
      it {expect(assigns[:task]).not_to be_new_record}
    end

    context "when admin edit task of other user" do
      before do
        session[:user_id] = admin.id
        get :edit, id: user_1_tasks.first.id
      end

      it {expect(response).to render_template(:edit)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
      it {expect(assigns[:task]).not_to be_new_record}
    end

    context "when admin try edit task with incorrect id" do
      before do
        session[:user_id] = admin.id
        get :edit, id: (Task.last.id + 1)
      end

      it {expect(response).to redirect_to(tasks_path)}
      it {expect(flash[:alert]).to eq("Task not found!")}
    end

    context "when user edit self task" do
      before do
        session[:user_id] = user_1.id
        get :edit, id: user_1_tasks.first.id
      end

      it {expect(response).to render_template(:edit)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
      it {expect(assigns[:task]).not_to be_new_record}
    end

    context "when user try edit other user task" do
      before do
        session[:user_id] = user_1.id
        get :edit, id: user_2_tasks.first.id
      end

      it {expect(response).to redirect_to(tasks_path)}
      it {expect(flash[:alert]).to eq("Task not found!")}
    end

    context "when user try edit unexisting task" do
      before do
        session[:user_id] = user_1.id
        get :edit, id: (Task.last.id + 1)
      end

      it {expect(response).to redirect_to(tasks_path)}
      it {expect(flash[:alert]).to eq("Task not found!")}
    end
  end

  # update
  describe '#update' do
    context 'when not logged in user try access then' do
      before {put :update, id: Task.first.id, task: FactoryGirl.attributes_for(:task)}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context "when admin update self task" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {put :update, id: admin.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "new name")}.to change{Task.count}.by(0)}
      end
      context do
        before {put :update, id: admin.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "another name")}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been updated successfuly!")}
        it {expect(admin.tasks.first).to be_instance_of(Task)}
        it {expect(admin.tasks.first.name).to eq("another name")}
      end
    end

    context "when admin update self task with empty name" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {put :update, id: admin.tasks.first.id, task: FactoryGirl.attributes_for(:task, user_id: admin.id, name: "")}.to change{Task.count}.by(0)}
      end
      context do
        before {put :update, id: admin.tasks.first.id, task: FactoryGirl.attributes_for(:task, user_id: admin.id, name: "")}

        it {expect(response).to render_template(:edit)}
        it {expect(flash[:alert]).to eq("Task data contains errors!")}
        it {expect(assigns[:task]).to be_instance_of(Task)}
        it {expect(assigns[:task].user_id).to eq(admin.id)}
        it {expect(assigns[:task].errors.messages.length).to eq(1)}
      end
    end

    context "when admin update task of other user" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {put :update, id: user_1.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "name 45")}.to change{Task.count}.by(0)}
      end
      context do
        before {put :update, id: user_1.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "name 45")}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been updated successfuly!")}
        it {expect(user_1.tasks.first).to be_instance_of(Task)}
        it {expect(user_1.tasks.first.name).to eq("name 45")}
      end
    end

    context "when user update self task" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {put :update, id: user_1.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "name 48*")}.to change{Task.count}.by(0)}
      end
      context do
        before {put :update, id: user_1.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "name 48*")}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been updated successfuly!")}
        it {expect(user_1.tasks.first).to be_instance_of(Task)}
        it {expect(user_1.tasks.first.name).to eq("name 48*")}
      end
    end

    context "when user update other user task" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {put :update, id: user_2.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "name 49*")}.to change{Task.count}.by(0)}
      end
      context do
        before {put :update, id: user_2.tasks.first.id, task: FactoryGirl.attributes_for(:task, name: "name 49*")}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:alert]).to eq("Task not found!")}
        it {expect(user_2.tasks.first.name).not_to eq("name 49*")}
      end
    end
  end

  # show
  describe '#show' do
    context 'when not logged in user try access then' do
      before {get :show, id: admin_tasks.first.id}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context "when admin show self task" do
      before do
        session[:user_id] = admin.id
        get :show, id: admin_tasks.first.id
      end

      it {expect(response).to render_template(:show)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(admin.id)}
      it {expect(assigns[:task]).not_to be_new_record}
    end

    context "when admin show other user task" do
      before do
        session[:user_id] = admin.id
        get :show, id: user_1.tasks.first.id
      end

      it {expect(response).to render_template(:show)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
      it {expect(assigns[:task]).not_to be_new_record}
    end

    context "when admin try show task with incorrect id" do
      before do
        session[:user_id] = admin.id
        get :show, id: (Task.last.id + 1)
      end

      it {expect(response).to redirect_to(tasks_path)}
      it {expect(flash[:alert]).to eq("Task not found!")}
    end

    context "when user show self task" do
      before do
        session[:user_id] = user_1.id
        get :show, id: user_1.tasks.first.id
      end

      it {expect(response).to render_template(:show)}
      it {expect(assigns[:task]).to be_instance_of(Task)}
      it {expect(assigns[:task].user_id).to eq(user_1.id)}
      it {expect(assigns[:task]).not_to be_new_record}
    end

    context "when user try show other user task" do
      before do
        session[:user_id] = user_1.id
        get :show, id: user_2_tasks.first.id
      end

      it {expect(response).to redirect_to(tasks_path)}
      it {expect(flash[:alert]).to eq("Task not found!")}
    end

    context "when user try show unexisting task" do
      before do
        session[:user_id] = user_1.id
        get :show, id: (Task.last.id + 1)
      end

      it {expect(response).to redirect_to(tasks_path)}
      it {expect(flash[:alert]).to eq("Task not found!")}
    end
  end

  # destroy
  describe '#destroy' do
    context 'when not logged in user try access then' do
      before {delete :destroy, id: Task.first.id}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context "when admin destroy self task" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: admin.tasks.first.id}.to change{Task.count}.by(-1)}
      end
      context do
        before {delete :destroy, id: admin.tasks.first.id}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been removed!")}
      end
    end

    context "when admin destroy task of other user" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: user_1.tasks.first.id}.to change{Task.count}.by(-1)}
      end
      context do
        before {delete :destroy, id: user_1.tasks.first.id}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been removed!")}
      end
    end

    context "when user destroy self task" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: user_1.tasks.first.id}.to change{Task.count}.by(-1)}
      end
      context do
        before {delete :destroy, id: user_1.tasks.first.id}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:notice]).to eq("Task has been removed!")}
      end
    end

    context "when user destroy other user task" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: user_2.tasks.first.id}.to change{Task.count}.by(0)}
      end
      context do
        before {delete :destroy, id: user_2.tasks.first.id}

        it {expect(response).to redirect_to(tasks_path)}
        it {expect(flash[:alert]).to eq("Task not found!")}
        it {expect(user_2.tasks.first.name).not_to eq("name 49*")}
      end
    end
  end

  # start
  describe '#start' do
    context 'when not logged user try access then' do
      before {post :start, id: admin.tasks.first.id}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context 'when admin set start status to self task' do
      before {session[:user_id] = admin.id}

      describe 'Task.started.count' do
        it {expect {post :start, id: admin.tasks.first.id}.to change{Task.started.count}.by(1)}
      end

      context do
        before {post :start, id: admin.tasks.first.id}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end
      end
    end

    context 'when admin set start status to other user task' do
      before {session[:user_id] = admin.id}

      describe 'Task.started.count' do
        it {expect {post :start, id: user_1.tasks.first.id}.to change{Task.started.count}.by(1)}
      end

      context do
        before {post :start, id: user_1.tasks.first.id}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end
      end
    end

    context 'when user set start status to self task' do
      before {session[:user_id] = user_1.id}

      describe 'Task.started.count' do
        it {expect {post :start, id: user_1.tasks.first.id}.to change{Task.started.count}.by(1)}
      end

      context do
        before {post :start, id: user_1.tasks.first.id}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end

        it 'response should contens datetime when status changed to started' do
          response_data = JSON.parse(response.body)
          expect(response_data['started_at']).to be_present
        end
      end
    end

    context 'when user set start status to other user task' do
      before {session[:user_id] = user_1.id}

      describe 'Task.started.count' do
        it {expect {post :start, id: user_2.tasks.first.id}.to change{Task.started.count}.by(0)}
      end

      context do
        before {post :start, id: user_2.tasks.first.id}

        it 'response should contens status equal ERROR' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("ERROR")
        end

        it 'response should contens reason of Error' do
          response_data = JSON.parse(response.body)
          expect(response_data['reason']).to be_present
        end
      end
    end

    context 'when user set start status to self finished task' do
      let!(:user_1_finished_task) {FactoryGirl.create(:finished_task, user: user_1)}
      before {session[:user_id] = user_1.id}

      describe 'Task.finished.count' do
        it {expect {post :start, id: user_1_finished_task.id}.to change{Task.started.count}.by(0)}
      end

      context do
        before {post :start, id: user_1_finished_task.id}

        it 'response should contens status equal ERROR' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("ERROR")
        end

        it 'response should contens reason of Error' do
          response_data = JSON.parse(response.body)
          expect(response_data['reason']).to be_present
        end
      end
    end
  end

  # finish
  describe '#finish' do
    let!(:started_admin_tasks) {FactoryGirl.create_pair(:started_task, user: admin)}
    let!(:started_user_1_tasks) {FactoryGirl.create_pair(:started_task, user: user_1)}
    let!(:started_user_2_tasks) {FactoryGirl.create_pair(:started_task, user: user_2)}

    context 'when not logged user try access then' do
      before {post :finish, id: admin.tasks.first.id}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context 'when admin set finish status to self task' do
      before {session[:user_id] = admin.id}

      describe 'Task.finished.count' do
        it {expect {post :finish, id: admin.tasks.started.first.id}.to change{Task.finished.count}.by(1)}
      end

      context do
        before {post :finish, id: admin.tasks.started.first.id}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end
      end
    end

    context 'when admin set finish status to other user task' do
      before {session[:user_id] = admin.id}

      describe 'Task.finished.count' do
        it {expect {post :finish, id: user_1.tasks.started.first.id}.to change{Task.finished.count}.by(1)}
      end

      context do
        before {post :finish, id: user_1.tasks.started.first.id}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end
      end
    end

    context 'when user set finish status to self task' do
      before {session[:user_id] = user_1.id}

      describe 'Task.finished.count' do
        it {expect {post :finish, id: user_1.tasks.started.first.id}.to change{Task.finished.count}.by(1)}
      end

      context do
        before {post :finish, id: user_1.tasks.started.first.id}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end

        it 'response should contens datetime when status changed to finished' do
          response_data = JSON.parse(response.body)
          expect(response_data['finished_at']).to be_present
        end
      end
    end

    context 'when user set finish status to other user task' do
      before {session[:user_id] = user_1.id}

      describe 'Task.finished.count' do
        it {expect {post :finish, id: user_2.tasks.started.first.id}.to change{Task.finished.count}.by(0)}
      end

      context do
        before {post :finish, id: user_2.tasks.started.first.id}

        it 'response should contens status equal ERROR' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("ERROR")
        end

        it 'response should contens reason of Error' do
          response_data = JSON.parse(response.body)
          expect(response_data['reason']).to be_present
        end
      end
    end

    context 'when user set finish status to self new task' do
      before {session[:user_id] = user_1.id}

      describe 'Task.finished.count' do
        it {expect {post :finish, id: user_1.tasks.initiated.first.id}.to change{Task.finished.count}.by(0)}
      end

      context do
        before {post :finish, id: user_1.tasks.initiated.first.id}

        it 'response should contens status equal ERROR' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("ERROR")
        end

        it 'response should contens reason of Error' do
          response_data = JSON.parse(response.body)
          expect(response_data['reason']).to be_present
        end
      end
    end
  end

  # assign_to
  describe '#assign_to' do
    context 'when not logged user try access then' do
      before {post :assign_to, id: admin.tasks.first.id}

      it {expect(response).to redirect_to(new_session_path)}
    end

    context 'when admin assign task from one user to another' do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :assign_to, id: user_1.tasks.first.id, user_id: user_2}.to change{user_1.tasks.count}.by(-1)}
        it {expect {post :assign_to, id: user_1.tasks.first.id, user_id: user_2}.to change{user_2.tasks.count}.by(1)}
      end

      context do
        before {post :assign_to, id: user_1.tasks.first.id, user_id: user_2}

        it 'response should contens status equal OK' do
          response_data = JSON.parse(response.body)
          expect(response_data['status']).to eq("OK")
        end
      end
    end

    context 'when user try reassign task to another user' do
      before do
        session[:user_id] = user_1.id
        post :assign_to, id: user_1.tasks.first.id, user_id: user_2
      end

      it 'response should contains ERROR in status' do
        response_data = JSON.parse(response.body)
        expect(response_data['status']).to eq("ERROR")
      end

      it 'response should contains reason' do
        response_data = JSON.parse(response.body)
        expect(response_data['reason']).to eq("Permission denied")
      end
    end

    context 'when admin try reassign unexisting task to another user' do
      before do
        session[:user_id] = admin.id
        post :assign_to, id: (Task.last.id + 1), user_id: user_2
      end

      it 'response should contains ERROR in status' do
        response_data = JSON.parse(response.body)
        expect(response_data['status']).to eq("ERROR")
      end

      it 'response should contains reason' do
        response_data = JSON.parse(response.body)
        expect(response_data['reason']).to eq("Task not found")
      end
    end

    context 'when admin try reassign task to unexisting user' do
      before do
        session[:user_id] = admin.id
        post :assign_to, id: user_1.tasks.first.id, user_id: (user_2.id + 1)
      end

      it 'response should contains ERROR in status' do
        response_data = JSON.parse(response.body)
        expect(response_data['status']).to eq("ERROR")
      end

      it 'response should contains reason' do
        response_data = JSON.parse(response.body)
        expect(response_data['reason']).to eq("User not found")
      end
    end
  end
end
