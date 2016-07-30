require 'rails_helper'

RSpec.describe Web::ApplicationController, type: :controller do
  context '.authenticate_user' do
    let!(:user) {FactoryGirl.create(:user)}

    context "when session[:user_id] present" do
      before do
        session[:user_id] = user.id
      end

      it "the current_user should contains instance of logged_in User" do
        controller.authenticate_user
        expect(assigns[:current_user]).to eq(user)
      end
    end

    context "when session[:user_id] is not present" do
      it "the method should redirect to new_sessions_path" do
        controller.current_user
        expect(assigns[:current_user]).to be_nil
      end
    end
  end
end
