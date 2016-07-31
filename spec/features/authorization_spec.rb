require 'rails_helper'

RSpec.describe 'Authorization' do
  let!(:admin) {FactoryGirl.create(:admin)}

  describe 'Login' do
    before do
      visit '/'
    end

    it 'successful authorization with correct credentials' do
      within('#login') do
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: "Password"
      end
      click_button "Login"
      expect(page).to have_content('Tasks list')
    end

    it 'failed login when specified incorrect email' do
      within('#login') do
        fill_in 'Email', with: "aa@bb.cc"
        fill_in 'Password', with: "Password"
      end

      click_button "Login"
      expect(page).to have_content('Email')
    end

    it 'failed login when specified incorrect password' do
      within('#login') do
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: "BadPassword"
      end

      click_button "Login"
      expect(page).to have_content('Email')
    end
  end

  describe 'Logout do' do
    before do
      visit '/'
      within('#login') do
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: "Password"
      end
      click_button "Login"
    end

    it 'use logout url to logout' do
      visit '/log_out'

      expect(page).to have_content('Email')
    end
  end
end
