# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organisation_id        :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_organisation_id       (organisation_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@heimv.local" }

  factory :user do
    organisation
    confirmed_at { Time.zone.now }
    email { generate(:email) }
    password { 'heimverwaltung' }

    trait :admin do
      role { 'admin' }
    end

    trait :manager do
      role { 'manager' }
    end

    trait :readonly do
      role { 'readonly' }
    end
  end
end
