FactoryGirl.define do
  sequence(:body) { |n| "Answer body #{n}" }

  factory :answer do
    body
  end

  factory :invalid_answer, class: 'Answer' do
    body nil
  end
end
