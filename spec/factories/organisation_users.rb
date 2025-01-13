# frozen_string_literal: true

# == Schema Information
#
# Table name: organisation_users
#
#  id              :bigint           not null, primary key
#  role            :integer          not null
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#  user_id         :bigint           not null
#

FactoryBot.define do
  factory :organisation_user do
    organisation
    user

    trait :none do
      role { 'none' }
    end

    trait :manager do
      role { 'manager' }
    end

    trait :readonly do
      role { 'readonly' }
    end
  end
end
