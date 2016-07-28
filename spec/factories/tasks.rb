FactoryGirl.define do
  factory :task do
    name  "Weak Up"
    user
    state "new"

    trait :started do
      after(:create) do |_task|
        _task.start
      end
    end

    trait :finished do
      state       "finished"
      finished_at {DateTime.now}
    end
  end
end
