require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  context '#new' do
    before {get :new}

    it {expect(response).to render_template(:new)}
    it {expect(response).to have_http_status(200)}
  end

  context "#create" do
    let!(:user) {FactoryGirl.create(:user, email: "user@example.com")}

    context "when entered correct credentials" do
      before {post :create, email: "user@example.com", password: "Password"}

      it {expect(session[:user_id]).to eq(user.id)}
      it {expect(response).to redirect_to(root_url)}
      it {expect(flash[:notice]).to eq("Logged in!")}
    end

    context "when entered incorrext email" do
      before {post :create, email: "other@example.com", password: "Password"}

      it {expect(session[:user_id]).to be_nil}
      it {expect(response).to render_template(:new)}
      it {expect(flash[:alert]).to eq("Invalid credentials! Please try again!")}
    end

    context "when entered incorrect password" do
      before {post :create, email: "user@example.com", password: "other"}

      it {expect(session[:user_id]).to be_nil}
      it {expect(response).to render_template(:new)}
      it {expect(flash[:alert]).to eq("Invalid credentials! Please try again!")}
    end
  end

  context "#destroy" do
    let(:user) {FactoryGirl.create(:user)}

    before {post :create, email: user.email, password: 'Password'}
    before {delete :destroy, id: user.id}

    it {expect(session[:user_id]).to be_nil}
    it {expect(response).to redirect_to(root_url)}
    it {expect(flash[:notice]).to eq("Logged out!")}
  end
end
