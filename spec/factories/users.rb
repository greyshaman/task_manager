FactoryGirl.define do
  sequence(:email) {|n| "test#{n}@example.com"}

  factory :user do
    email
    password              "Password"
    password_confirmation "Password"

    before(:create) do |user|
      user.encrypt_password
    end

    factory :admin do
      role "ADMIN"
    end
  end
end
