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

class BookingCategory < ApplicationRecord
  include RankedModel
  include Discard::Model
  extend Mobility

  belongs_to :organisation, inverse_of: :booking_categories
  has_many :bookings, inverse_of: :category, dependent: :restrict_with_error

  scope :ordered, -> { rank(:ordinal) }
  ranks :ordinal, with_same: :organisation_id

  translates :title, :description, column_suffix: '_i18n', locale_accessors: true

  delegate :to_s, to: :title

  validates :key, length: { minimum: 3, maximum: 50 }, uniqueness: { scope: :organisation_id }, allow_blank: true
end
