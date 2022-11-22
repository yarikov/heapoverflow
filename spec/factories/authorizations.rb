FactoryBot.define do
  factory :authorization do
    user { nil }
    provider { 'provider' }
    uid { '12345' }
  end
end
