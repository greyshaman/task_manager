require 'rails_helper'
require 'support/capybara_helpers'

RSpec.configure do |c|
  c.include CapybaraHelpers
end

RSpec.describe 'Authorization' do
  PASSWORD = "Password"
  let!(:admin) {FactoryGirl.create(:admin)}
  let!(:users) {FactoryGirl.create_pair(:user)}

  let!(:admin_tasks) {FactoryGirl.create_pair(:task, user: admin)}
  let!(:user_1_tasks) {FactoryGirl.create_pair(:task, user: users.first)}
  let!(:user_2_tasks) {FactoryGirl.create_pair(:task, user: users.second)}

  context 'when admin access' do
    before do
      login_helper admin.email, PASSWORD
    end

    it {expect(page).to have_selector("table.table")}
    it {expect(page).to have_selector("table.table tr.item-row", count: Task.count)}
    it {expect(page).to have_selector("table.table tr.item-row:first td", count: 7)}
  end
end
