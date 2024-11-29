# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_categories
#
#  id               :integer          not null, primary key
#  organisation_id  :integer          not null
#  key              :string
#  title_i18n       :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ordinal          :integer
#  description_i18n :jsonb
#  discarded_at     :datetime
#
# Indexes
#
#  index_booking_categories_on_discarded_at             (discarded_at)
#  index_booking_categories_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_booking_categories_on_ordinal                  (ordinal)
#  index_booking_categories_on_organisation_id          (organisation_id)
#

FactoryBot.define do
  factory :booking_category do
    organisation { nil }
    sequence(:key) { |i| "category_#{i}" }
    title_i18n { Faker::Commerce.department }
  end
end
