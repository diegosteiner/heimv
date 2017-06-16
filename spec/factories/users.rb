# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    confirmed_at Time.zone.now
    name 'Test User'
    email 'test@example.com'
    password 'please123'

    trait :admin do
      role 'admin'
    end
  end
end
