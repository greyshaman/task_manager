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
end
