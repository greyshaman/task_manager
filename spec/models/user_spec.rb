require 'rails_helper'

RSpec.describe User, type: :model do
  context "as attributes" do
    it {is_expected.to have_db_column(:email).of_type(:string).with_options(null: false)}
    it {is_expected.to have_db_column(:encrypted_password).of_type(:string).with_options(null: false)}
    it {is_expected.to have_db_column(:role).of_type(:string).with_options(null: false, default: 'USER')}

    it {is_expected.to have_db_index(:email).unique(true)}
  end

  context "as associations" do
    it {is_expected.to have_many(:tasks).dependent(:destroy)}
  end

  context "as validations" do

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

      context "for user" do
        let!(:user) {FactoryGirl.create(:user)}

        it {expect(user).to be_user}
        it {expect(user).not_to be_admin}
      end

      context "for admin" do
        let!(:admin) {FactoryGirl.create(:admin)}

        it {expect(admin).to be_admin}
        it {expect(admin).not_to be_user}
      end
    end
  end

  context ".authentication" do
    let!(:user) {FactoryGirl.create(:user, email: 'user@example.com')}

    it "should return user instance when specified correct email and password" do
      expect(User.authenticate('user@example.com', 'Password')).to be_instance_of(User)
    end

    it "should return nil when specified incorrect email" do
      expect(User.authenticate("other@example.com", "Password")).to be_nil
    end

    it "should return nil when specified incorrect password" do
      expect(User.authenticate("user@example.com", "Password1")).to be_nil
    end
  end

  context '#user?' do
    let (:user) {FactoryGirl.create(:user)}

    it {expect(user.user?).to be true}
    it {expect(user.admin?).to be false}
  end

  context '#admin?' do
    let (:admin) {FactoryGirl.create(:admin)}

    it {expect(admin.admin?).to be true}
    it {expect(admin.user?).to be false}
  end
end
