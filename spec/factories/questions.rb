# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    user
    sequence(:title) { |n| "Question title #{n}" }
    sequence(:body)  { |n| "Question body #{n}" }
    tag_list { 'question' }

    trait :invalid do
      title { nil }
      body { nil }
    end

    trait :with_answers do
      after(:create) do |question, _evaluator|
        create_list(:answer, 2, question: question)
      end
    end

    trait :with_comments do
      after(:create) do |question, _evaluator|
        create_list(:comment, 2, commentable: question)
      end
    end

    trait :reindex do
      after(:create) do |question, _evaluator|
        question.reindex(refresh: true)
      end
    end
  end
end
