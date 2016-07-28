FactoryGirl.define do
  factory :task do
    name  "Weak Up"
    user
    state "new"

    trait :started do
      state       "started"
      started_at  {DateTime.now}
    end

    trait :finished do
      state       "finished"
      finished_at {DateTime.now}
    end
  end
end
