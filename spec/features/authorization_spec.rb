require 'rails_helper'
require 'support/capybara_helpers'

RSpec.configure do |c|
  c.include CapybaraHelpers
end

RSpec.describe 'Authorization' do
  let!(:admin) {FactoryGirl.create(:admin)}

  describe 'Login' do
    it 'successful authorization with correct credentials' do
      login_helper admin.email, "Password"

      expect(page).to have_content('Tasks list')
    end

    it 'failed login when specified incorrect email' do
      login_helper "aa@bb.cc", "Password"
      expect(page).to have_content('Email')
    end

    it 'failed login when specified incorrect password' do
      login_helper admin.email, "BadPassword"
      expect(page).to have_content('Email')
    end
  end

  describe 'Logout do' do
    before do
      login_helper admin.email, "Password"
    end

    it 'use logout url to logout' do
      visit '/log_out'

      expect(page).to have_content('Email')
    end
  end
end
