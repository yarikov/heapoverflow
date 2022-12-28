# frozen_string_literal: true

FactoryBot.define do
  factory :answer do
    user
    question
    sequence(:body) { |n| "Answer body #{n}" }

    factory :old_answer do
      created_at { 3.days.ago }
    end

    trait :reindex do
      after(:create) do |answer, _evaluator|
        answer.reindex(refresh: true)
      end
    end
  end

  factory :invalid_answer, class: 'Answer' do
    body { nil }
  end
end
