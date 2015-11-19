FactoryGirl.define do
  factory :answer do
    body 'MyAnswer'
  end

  factory :invalid_answer, class: 'Answer' do
    body nil
  end
end
