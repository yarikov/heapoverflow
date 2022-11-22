FactoryBot.define do
  factory :question do
    user
    sequence(:title) { |n| "Question title #{n}" }
    sequence(:body)  { |n| "Question body #{n}" }
    tag_list { 'question' }
  end

  factory :invalid_question, class: 'Question' do
    title { nil }
    body { nil }
  end
end
