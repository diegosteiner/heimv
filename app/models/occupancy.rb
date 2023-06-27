# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id                 :uuid             not null, primary key
#  begins_at          :datetime         not null
#  color              :string
#  ends_at            :datetime         not null
#  ignore_conflicting :boolean          default(FALSE), not null
#  linked             :boolean          default(TRUE)
#  occupancy_type     :integer          default("free"), not null
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  occupiable_id      :bigint           not null
#
# Indexes
#
#  index_occupancies_on_begins_at       (begins_at)
#  index_occupancies_on_ends_at         (ends_at)
#  index_occupancies_on_occupancy_type  (occupancy_type)
#  index_occupancies_on_occupiable_id   (occupiable_id)
#
# Foreign Keys
#
#  fk_rails_...  (occupiable_id => occupiables.id)
#

class Occupancy < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  OCCUPANCY_TYPES = { free: 0, tentative: 1, occupied: 2, closed: 3 }.freeze

  include Timespanable

  timespan :begins_at, :ends_at
  belongs_to :occupiable, inverse_of: :occupancies
  belongs_to :booking, inverse_of: :occupancies, optional: true, touch: true

  has_one :organisation, through: :occupiable

  enum occupancy_type: OCCUPANCY_TYPES

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :blocking, -> { where(occupancy_type: %i[tentative occupied closed]) }

  before_validation :update_from_booking
  validates :color, format: { with: COLOR_REGEX }, allow_blank: true
  validate on: %i[public_create public_update agent_booking manage_create manage_update] do
    errors.add(:base, :occupancy_conflict) if !ignore_conflicting && conflicting?
  end

  validate do
    errors.add(:occupiable_id, :invalid) if booking && organisation && !organisation == booking.organisation
    errors.add(:linked, :invalid) if linked && booking.blank?
  end

  def conflicting?(...)
    conflicting(...)&.any?
  end

  def to_s
    "#{occupiable}: #{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)} #{occupancy_type}"
  rescue StandardError
    super
  end

  # rubocop:disable Metrics/AbcSize
  def conflicting(margin = occupiable&.settings&.booking_margin || 0)
    return if begins_at.blank? || ends_at.blank? || occupiable.blank?

    occupiable.occupancies.blocking.at(from: begins_at - margin - 1, to: ends_at + margin + 1)
              .where.not(id: id)
  end
  # rubocop:enable Metrics/AbcSize

  def color=(value)
    super(value.presence) if value != color
  end

  def color
    super.presence || booking&.occupancy_color || (organisation &&
      organisation.settings.occupancy_colors[occupancy_type&.to_sym])
  end

  def update_from_booking
    return if !linked || booking.blank?

    assign_attributes(begins_at: booking.begins_at, ends_at: booking.ends_at,
                      occupancy_type: booking.occupancy_type, ignore_conflicting: booking.ignore_conflicting)
  end
end
