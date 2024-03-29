# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email)     { |n| "user#{n}@test.com" }
    sequence(:full_name) { |n| "Vasya#{n} Pupkin" }
    password { '12345678' }
    password_confirmation { '12345678' }
    confirmed_at { Time.zone.now }

    factory :user_with_profile do
      avatar { Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images/avatar.png'), 'image/png') }
      sequence(:description) { |n| "Description #{n}" }
      sequence(:location)    { |n| "Pupkino #{n}" }
      sequence(:website)     { |n| "http://vasya#{n}.com" }
      sequence(:twitter)     { |n| "http://twitter.com/vasya#{n}" }
      sequence(:github)      { |n| "http://github.com/vasya#{n}" }
    end

    trait :reindex do
      after(:create) do |user, _evaluator|
        user.reindex(refresh: true)
      end
    end
  end
end
