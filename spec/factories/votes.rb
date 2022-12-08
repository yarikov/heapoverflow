# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    factory :upvote do
      value { 1 }
    end

    factory :downvote do
      value { -1 }
    end
  end
end
