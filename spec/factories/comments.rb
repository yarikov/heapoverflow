FactoryGirl.define do
  factory :comment do
    sequence(:body) { |n| "Question comment #{n}" }
  end

  factory :invalid_comment, class: 'Comment' do
    body nil
  end
end
