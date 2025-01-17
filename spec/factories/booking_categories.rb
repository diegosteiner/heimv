# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_categories
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb            not null
#  discarded_at     :datetime
#  key              :string
#  ordinal          :integer
#  title_i18n       :jsonb            not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#

FactoryBot.define do
  factory :booking_category do
    organisation { nil }
    sequence(:key) { |i| "category_#{i}" }
    title { Faker::Commerce.department }
  end
end
