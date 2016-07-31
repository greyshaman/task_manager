require 'rails_helper'

RSpec.describe 'web/tasks/index.html.slim' do
  PASSWORD = "Password"
  let!(:admin) {FactoryGirl.create(:admin, password: PASSWORD, password_confirmation: PASSWORD)}
  let!(:users) {FactoryGirl.create_pair(:user, password: PASSWORD, password_confirmation: PASSWORD)}

  let!(:admin_tasks) {FactoryGirl.create_pair(:task, user: admin)}
  let!(:user_1_tasks) {FactoryGirl.create_pair(:task, user: users.first)}
  let!(:user_2_tasks) {FactoryGirl.create_pair(:task, user: users.second)}

  context ' when tasks list is not empty' do
    context 'shuld render all tasks' do
      before do
        assign(:tasks, Task.all)
        render
      end

      it {expect(rendered).to have_selector(".container")}
      it {expect(rendered).to have_selector("table.table")}
      it {expect(rendered).to have_selector("table.table tr.item-row", count: Task.count)}
      it {expect(rendered).to have_selector("table.table tr.item-row:first td", count: 6)}
    end
  end
end
