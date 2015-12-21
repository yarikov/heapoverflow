FactoryGirl.define do
  factory :vote do
    factory :upvote do
      value 1
    end

    factory :downvote do
      value(-1)
    end
  end
end
