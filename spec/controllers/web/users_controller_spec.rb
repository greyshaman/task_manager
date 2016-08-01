require 'rails_helper'

RSpec.describe Web::UsersController, type: :controller do
  let!(:admin) {FactoryGirl.create(:admin)}
  let!(:user_1) {FactoryGirl.create(:user)}
  let!(:user_2) {FactoryGirl.create(:user)}
  #index
  describe '#index' do
    context 'when not logged in user try access then' do
      before {get :index}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when admin access" do
      before do
        session[:user_id] = admin.id
        get :index
      end

      it {expect(response).to render_template(:index)}
      it {expect(assigns[:users].length).to eq(User.count)}
    end

    context "when user access" do
      before do
        session[:user_id] = user_1.id
        get :index
      end

      it {expect(response).to redirect_to(user_path(user_1))}
      it {expect(flash[:alert]).to eq("Permission denied!")}
    end
  end

  #new
  describe '#new' do
    context 'when not logged in user try access then' do
      before {get :new}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when user access" do
      before do
        session[:user_id] = user_1.id
        get :new
      end

      it {expect(response).to redirect_to(user_path(user_1))}
      it {expect(flash[:alert]).to eq("Permission denied!")}
    end

    context "when admin access" do
      before do
        session[:user_id] = admin.id
        get :new
      end

      it {expect(response).to render_template(:new)}
      it {expect(assigns[:user]).to be_instance_of(User)}
    end
  end

  #create
  describe '#create' do
    context 'when not logged in user try access then' do
      before {post :create, user: FactoryGirl.attributes_for(:user)}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when user access" do
      before do
        session[:user_id] = user_1.id
        post :create, user: FactoryGirl.attributes_for(:user)
      end

      it {expect(response).to redirect_to(user_path(user_1))}
      it {expect(flash[:alert]).to eq("Permission denied!")}
    end

    context "when admin create new user" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, user: FactoryGirl.attributes_for(:user)}.to change{User.count}.by(1)}
      end
      context do
        before {post :create, user: FactoryGirl.attributes_for(:user)}

        it {expect(response).to redirect_to(users_path)}
        it {expect(flash[:notice]).to eq("User has been created successfuly!")}
      end
    end

    context "when admin create new user with incorrect email" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, user: FactoryGirl.attributes_for(:user, email: "incorrect.email.format")}.to change{User.count}.by(0)}
      end
      context do
        before {post :create, user: FactoryGirl.attributes_for(:user, email: "incorrect.email.format")}

        it {expect(response).to render_template(:new)}
        it {expect(flash[:alert]).to eq("User data contains errors!")}
        it {expect(assigns[:user].errors.messages.length).to eq(1)}
      end
    end

    context "when admin create new user with empty email" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, user: FactoryGirl.attributes_for(:user, email: "")}.to change{User.count}.by(0)}
      end
      context do
        before {post :create, user: FactoryGirl.attributes_for(:user, email: "")}

        it {expect(response).to render_template(:new)}
        it {expect(flash[:alert]).to eq("User data contains errors!")}
        it {expect(assigns[:user].errors.messages.length).to eq(1)}
      end
    end

    context "when admin create new user with existing email" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, user: FactoryGirl.attributes_for(:user, email: User.last.email)}.to change{User.count}.by(0)}
      end
      context do
        before {post :create, user: FactoryGirl.attributes_for(:user, email: User.last.email)}

        it {expect(response).to render_template(:new)}
        it {expect(flash[:alert]).to eq("User data contains errors!")}
        it {expect(assigns[:user].errors.messages.length).to eq(1)}
      end
    end

    context "when admin create new user with unmatched passwords pair" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {post :create, user: FactoryGirl.attributes_for(:user, password: "password1", password_confirmation: "password2")}.to change{User.count}.by(0)}
      end
      context do
        before {post :create, user: FactoryGirl.attributes_for(:user, password: "password1", password_confirmation: "password2")}

        it {expect(response).to render_template(:new)}
        it {expect(flash[:alert]).to eq("User data contains errors!")}
        it {expect(assigns[:user].errors.messages.length).to eq(2)}
      end
    end
  end

  #edit
  describe '#edit' do
    context 'when not logged in user try access then' do
      before {get :edit, id: user_1.id}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when admin access" do
      before do
        session[:user_id] = admin.id
        get :edit, id: user_1.id
      end

      it {expect(response).to render_template(:edit)}
      it {expect(assigns[:user]).to be_instance_of(User)}
      it {expect(assigns[:user].id).to eql(user_1.id)}
    end

    context "when user access to self profile" do
      before do
        session[:user_id] = user_1.id
        get :edit, id: user_1.id
      end

      it {expect(response).to render_template(:edit)}
      it {expect(assigns[:user]).to be_instance_of(User)}
      it {expect(assigns[:user].id).to eql(user_1.id)}
    end

    context "when user access to other profile" do
      before do
        session[:user_id] = user_1.id
        get :edit, id: user_2.id
      end

      it {expect(response).to redirect_to(user_path(user_1))}
      it {expect(flash[:alert]).to eq("Permission denied!")}
    end

    context "when admin access with incorrect id param" do
      before do
        session[:user_id] = admin.id
        get :edit, id: (User.last.id + 1)
      end

      it {expect(response).to redirect_to(users_path)}
      it {expect(flash[:alert]).to eq("User not found!")}
    end
  end

  #update
  describe '#update' do
    context 'when not logged in user try access then' do
      before {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user)}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when admin update user profile" do
      before {session[:user_id] = admin.id}

      describe 'User.count' do
        it {expect {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, email: "master@example.com")}.to change{User.count}.by(0)}
      end
      context do
        before {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, email: "master@example.com")}

        it {expect(response).to redirect_to(users_path)}
        it {expect(flash[:notice]).to eq("User has been updated successfuly!")}
        it {expect(user_1.reload.email).to eq("master@example.com")}
      end
    end

    context "when admin update password to user " do
      before {session[:user_id] = admin.id}

      describe 'User.count' do
        it {expect {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, password: "newpassword", password_confirmation: "newpassword")}.to change{User.count}.by(0)}
      end
      context do
        before do
          @old_enc_pass = user_1.encrypted_password
          put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, password: "newpassword", password_confirmation: "newpassword")
        end

        it {expect(response).to redirect_to(users_path)}
        it {expect(flash[:notice]).to eq("User has been updated successfuly!")}
        it {expect(user_1.reload.encrypted_password).not_to eq(@old_enc_pass)}
      end
    end

    context "when admin update user profile with incorrect email" do
      before {session[:user_id] = admin.id}

      describe 'User.count' do
        it {expect {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, email: "master.example.com")}.to change{User.count}.by(0)}
      end
      context do
        before {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, email: "master.example.com")}

        it {expect(response).to render_template(:edit)}
        it {expect(flash[:alert]).to eq("User data contains errors!")}
        it {expect(assigns[:user].errors.messages.length).to eq(1)}
        it {expect(user_1.reload.email).not_to eq("master@example.com")}
      end
    end

    context "when admin try update user profile with incorrect id" do
      before {session[:user_id] = admin.id}

      describe 'User.count' do
        it {expect {put :update, id: (User.last.id + 1), user: FactoryGirl.attributes_for(:user, email: "master@example.com")}.to change{User.count}.by(0)}
      end
      context do
        before {put :update, id: (User.last.id + 1), user: FactoryGirl.attributes_for(:user, email: "master@example.com")}

        it {expect(response).to redirect_to(users_path)}
        it {expect(flash[:alert]).to eq("User not found!")}
      end
    end

    context "when user update self profile" do
      before {session[:user_id] = user_1.id}

      describe 'User.count' do
        it {expect {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, email: "master@example.com")}.to change{User.count}.by(0)}
      end
      context do
        before {put :update, id: user_1.id, user: FactoryGirl.attributes_for(:user, email: "master@example.com")}

        it {expect(response).to redirect_to(user_path(user_1))}
        it {expect(flash[:notice]).to eq("User has been updated successfuly!")}
        it {expect(user_1.reload.email).to eq("master@example.com")}
      end
    end

    context "when user try update other user profile" do
      before {session[:user_id] = user_1.id}

      describe 'User.count' do
        it {expect {put :update, id: user_2.id, user: FactoryGirl.attributes_for(:user, email: "master@example.com")}.to change{User.count}.by(0)}
      end
      context do
        before {put :update, id: user_2.id, user: FactoryGirl.attributes_for(:user, email: "master@example.com")}

        it {expect(response).to redirect_to(user_path(user_1))}
        it {expect(flash[:alert]).to eq("Permission denied!")}
        it {expect(user_2.reload.email).not_to eq("master@example.com")}
      end
    end
  end

  #show
  describe '#show' do
    context 'when not logged in user try access then' do
      before {get :show, id: user_1.id}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when admin access" do
      before do
        session[:user_id] = admin.id
        get :show, id: user_1.id
      end

      it {expect(response).to render_template(:show)}
      it {expect(assigns[:user]).to be_instance_of(User)}
      it {expect(assigns[:user].id).to eql(user_1.id)}
    end

    context "when admin try to access to user profile with incorrect id" do
      before do
        session[:user_id] = admin.id
        get :show, id: (User.last.id + 1)
      end

      it {expect(response).to redirect_to(users_path)}
      it {expect(flash[:alert]).to eq("User not found!")}
    end

    context "when user access to self profile" do
      before do
        session[:user_id] = user_1.id
        get :show, id: user_1.id
      end

      it {expect(response).to render_template(:show)}
      it {expect(assigns[:user]).to be_instance_of(User)}
      it {expect(assigns[:user].id).to eql(user_1.id)}
    end

    context "when user try to access to other user profile" do
      before do
        session[:user_id] = user_1.id
        get :show, id: user_2.id
      end

      it {expect(response).to redirect_to(user_path(user_1))}
      it {expect(flash[:alert]).to eq("Permission denied!")}
    end

    context "when user try to access to user profile with incorrect id" do
      before do
        session[:user_id] = user_1.id
        get :show, id: (User.last.id + 1)
      end

      it {expect(response).to redirect_to(user_path(user_1))}
      it {expect(flash[:alert]).to eq("Permission denied!")}
    end
  end

  #destroy
  describe '#destroy' do
    context 'when not logged in user try access then' do
      before {delete :destroy, id: user_1.id}

      it {expect(response).to redirect_to(log_in_path)}
    end

    context "when admin destroy other account" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: user_1.id}.to change{User.count}.by(-1)}
      end
      context do
        before {delete :destroy, id: user_1.id}

        it {expect(response).to redirect_to(users_path)}
        it {expect(flash[:notice]).to eq("User has been removed!")}
      end
    end

    context "when admin try to destroy self" do
      before {session[:user_id] = admin.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: admin.id}.to change{User.count}.by(0)}
      end
      context do
        before {delete :destroy, id: admin.id}

        it {expect(response).to redirect_to(users_path)}
        it {expect(flash[:alert]).to eq("Admin cannot remove himself!")}
      end
    end

    context "when user try to destroy any account" do
      before {session[:user_id] = user_1.id}

      describe 'Task.count' do
        it {expect {delete :destroy, id: user_1.id}.to change{User.count}.by(0)}
      end
      context do
        before {delete :destroy, id: user_1.id}

        it {expect(response).to redirect_to(user_path(user_1))}
        it {expect(flash[:alert]).to eq("Permission denied!")}
      end
    end
  end
end
