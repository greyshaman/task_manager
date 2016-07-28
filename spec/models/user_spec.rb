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
        it {is_expected.to validate_uniqueness_of(:email)}
      end

      it {is_expected.to validate_presence_of(:email)}
      it {is_expected.to allow_value('aa@bb.cc').for(:email)}
      it {is_expected.not_to allow_value('aa.bb.cc').for(:email)}
    end

    context "encrypted_password" do
      it {is_expected.to validate_presence_of(:encrypted_password)}
    end

    context "password" do
      it {is_expected.to validate_confirmation_of(:password)}
    end

    context "roles" do
      it {is_expected.to validate_inclusion_of(:role).in_array(%w(ADMIN USER))}
    end
  end
end
