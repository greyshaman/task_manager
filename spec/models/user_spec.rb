require 'rails_helper'

RSpec.describe User, type: :model do
  context "attributes" do
    it {expect(subject).to have_db_column(:email).of_type(:string).with_options(null: false)}
    it {expect(subject).to have_db_column(:encrypted_password).of_type(:string).with_options(null: false)}
    it {expect(subject).to have_db_column(:role).of_type(:string).with_options(null: false, default: 'USER')}

    it {expect(subject).to have_db_index(:email).unique(true)}

  end

  context "validation" do
    subject {FactoryGirl.create(:user)}

    it {expect(subject).to validate_uniqueness_of(:email)}
    it {expect(subject).to validate_presence_of(:email)}
  end
end
