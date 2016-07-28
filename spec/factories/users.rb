FactoryGirl.define do
  factory :user do
    email                 "test@example.com"
    password              "Password"
    password_confirmation "Password"

    before(:create) do |user|
      user.encrypt_password
    end
  end
end
