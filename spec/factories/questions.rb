FactoryGirl.define do
  sequence(:title) { |n| "Question title #{n}" }

  factory :question do
    title
    body 'Question body'
  end

  factory :invalid_question, class: 'Question' do
    title nil
    body nil
  end
end
