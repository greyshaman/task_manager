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
      after(:create) do |_task|
        _task.start
        _task.finish
      end
    end

    factory :started_task, traits: [:started]
    factory :finished_task, traits: [:finished]
  end
end
