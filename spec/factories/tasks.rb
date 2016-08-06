FactoryGirl.define do
  factory :task do
    name  "Weak Up"
    user

    trait :started do
      after(:create) do |task|
        task.start
      end
    end

    trait :finished do
      after(:create) do |task|
        task.start
        task.finish
      end
    end

    factory :started_task, traits: [:started]
    factory :finished_task, traits: [:finished]
  end
end
