require 'rails_helper'

RSpec.describe User, type: :model do
  context "attributes" do
    it {expect(subject).to have_db_column(:email).of_type(:string).with_options(null: false)}
    it {expect(subject).to have_db_column(:encrypted_password).of_type(:string).with_options(null: false)}
    it {expect(subject).to have_db_column(:role).of_type(:string).with_options(null: false, default: 'USER')}

    it {expect(subject).to have_db_index(:email).unique(true)}

  end

  context "validation" do

    context "email field" do
      context "uniqueness" do
        subject {FactoryGirl.create(:user)}
        it {expect(subject).to validate_uniqueness_of(:email)}
      end

      it {expect(subject).to validate_presence_of(:email)}
      it {expect(subject).to allow_value('aa@bb.cc').for(:email)}
    end
  end
end
