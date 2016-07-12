FactoryGirl.define do
  factory :answer do
    user
    sequence(:body) { |n| "Answer body #{n}" }

    factory :old_answer do
      created_at 3.days.ago
    end
  end

  factory :invalid_answer, class: 'Answer' do
    body nil
  end
end
