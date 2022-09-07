# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_categories
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  key              :string
#  ordinal          :integer
#  title_i18n       :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_booking_categories_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_booking_categories_on_ordinal                  (ordinal)
#  index_booking_categories_on_organisation_id          (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
class BookingCategory < ApplicationRecord
  include RankedModel
  extend Mobility

  belongs_to :organisation, inverse_of: :booking_categories
  has_many :bookings, inverse_of: :category, dependent: :restrict_with_error

  scope :ordered, -> { rank(:ordinal) }
  ranks :ordinal, with_same: :organisation_id

  translates :title, :description, column_suffix: '_i18n', locale_accessors: true

  delegate :to_s, to: :title

  validates :key, length: { minimum: 3, maximum: 50 }, allow_nil: true
end
