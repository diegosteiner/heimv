# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@hv.dev" }

  factory :user do
    confirmed_at { Time.zone.now }
    email { generate(:email) }
    password { 'heimverwaltung' }

    trait :admin do
      role { 'admin' }
    end
  end
end
