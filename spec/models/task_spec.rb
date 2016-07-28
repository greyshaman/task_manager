require 'rails_helper'

RSpec.describe Task, type: :model do
  context "attributes" do
    it {is_expected.to have_db_column(:name).of_type(:string).with_options(null: false)}
    it {is_expected.to have_db_column(:description).of_type(:text)}
    it {is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false)}
    it {is_expected.to have_db_column(:state).of_type(:string).with_options(null: false, default: 'new')}
    it {is_expected.to have_db_column(:started_at).of_type(:datetime)}
    it {is_expected.to have_db_column(:finished_at).of_type(:datetime)}
  end

  context "associations" do
    it {is_expected.to belong_to(:user)}
  end

  context "validations" do
    it {is_expected.to validate_presence_of(:name)}
    it {is_expected.to validate_presence_of(:user_id)}
  end

  context "in new instance" do
    it {expect(subject.state).to eql("new") }
  end

  context "state" do
    describe "new" do
      subject {FactoryGirl.create(:task)}
      it 'should be an initial state' do
        is_expected.to be_new
      end

      it 'shoudld be satrted after transition from :new to :started' do
        subject.start
        is_expected.to be_started
        expect(subject.started_at).to be_present
      end
    end

    describe "started" do
      subject {FactoryGirl.create(:task, :started)}

      it 'should be finished after transition from :started to :finished' do
        is_expected.to be_started
        subject.finish
        is_expected.to be_finished
        expect(subject.finished_at).to be_present
      end
    end
  end
end
