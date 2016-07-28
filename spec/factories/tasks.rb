FactoryGirl.define do
  factory :task do
    name "Weak Up"
    user
    state "new"

    trait :started do
      state "started"
    end

    trait :finished do
      state "finished"
    end
  end
end
