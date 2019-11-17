# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  role                   :integer
#

FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@hv.dev" }

  factory :user do
    organisation
    confirmed_at { Time.zone.now }
    email { generate(:email) }
    password { 'heimverwaltung' }

    trait :admin do
      role { 'admin' }
    end
  end
end
