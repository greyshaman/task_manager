require 'rails_helper'

RSpec.describe User, type: :model do
  context "attributes" do
    it {expect(subject).to have_db_column(:email)}
  end
end
