FactoryBot.define do
  factory :comment do
    user
    sequence(:body) { |n| "Question comment #{n}" }

    factory :old_comment do
      created_at { 3.days.ago }
    end

    trait :reindex do
      after(:create) do |comment, _evaluator|
        comment.reindex(refresh: true)
      end
    end
  end

  factory :invalid_comment, class: 'Comment' do
    body { nil }
  end
end
