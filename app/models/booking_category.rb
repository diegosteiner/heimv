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
