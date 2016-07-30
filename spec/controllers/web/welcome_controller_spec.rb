require 'rails_helper'

RSpec.describe Web::WelcomeController, type: :controller do
  context '#index' do
    let!(:user) {FactoryGirl.create(:user)}

    context 'for logged in user' do
      before do
        session[:user_id] = user.id
        get :index
      end

      it {expect(response).to redirect_to(tasks_path)}
    end

    context 'for not logged in user' do
      before do
        get :index
      end

      it {expect(response).to redirect_to(new_session_path)}
    end
  end
end
