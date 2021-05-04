# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_purposes
#
#  id              :bigint           not null, primary key
#  key             :string
#  position        :integer
#  title_i18n      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_booking_purposes_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_booking_purposes_on_organisation_id          (organisation_id)
#  index_booking_purposes_on_position                 (position)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
class BookingPurpose < ApplicationRecord
  include RankedModel
  extend Mobility

  belongs_to :organisation, inverse_of: :booking_purposes
  has_many :bookings, inverse_of: :purpose, dependent: :restrict_with_error, foreign_key: :purpose_id

  scope :ordered, -> { rank(:position) }

  ranks :position, with_same: :organisation_id

  translates :title, column_suffix: '_i18n', locale_accessors: true

  delegate :to_s, to: :title

  def to_liquid
    to_s
  end
end
