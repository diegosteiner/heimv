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
# Indexes
#
#  index_booking_categories_on_discarded_at             (discarded_at)
#  index_booking_categories_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_booking_categories_on_ordinal                  (ordinal)
#  index_booking_categories_on_organisation_id          (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  factory :booking_category do
    organisation { nil }
    sequence(:key) { |i| "category_#{i}" }
    title { Faker::Commerce.department }
  end
end
