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
#  occupancy_type     :integer          default("pending"), not null
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  occupiable_id      :bigint           not null
#

class Occupancy < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  OCCUPANCY_TYPES = { pending: 0, tentative: 1, occupied: 2, closed: 3, free: 4, reserved: 5 }.freeze

  include Timespanable

  timespan :begins_at, :ends_at
  belongs_to :occupiable, inverse_of: :occupancies
  belongs_to :booking, inverse_of: :occupancies, optional: true, touch: true

  has_one :organisation, through: :occupiable

  enum :occupancy_type, OCCUPANCY_TYPES

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :occupancy_calendar, lambda {
    where.not(occupancy_type: %i[pending free]).or(where(occupancy_type: :free, booking: nil))
  }

  before_validation :update_from_booking
  validates :occupancy_type, presence: true
  validates :color, format: { with: COLOR_REGEX }, allow_blank: true
  validate if: ->(occupancy) { occupancy.validation_context != :ignore_conflicting } do
    errors.add(:base, :occupancy_conflict) if !ignore_conflicting && !free? && conflicting?
  end
  validate on: %i[manage_create manage_update] do
    errors.add(:begins_at, :invalid) if linked && begins_at != booking&.begins_at
    errors.add(:ends_at, :invalid) if linked && ends_at != booking&.ends_at
  end
  validate do
    errors.add(:occupiable_id, :invalid) if booking && organisation && !organisation == booking.organisation
    errors.add(:linked, :invalid) if linked && booking.blank?
  end

  def conflicting?(...)
    conflicting(...)&.exists?
  end

  def conflicting(conflicting_occupancy_types = %i[occupied closed reserved], # rubocop:disable Metrics/AbcSize
                  margin: occupiable&.settings&.booking_margin || 0)
    return unless begins_at.present? && ends_at.present? && occupiable.present?

    occupiable.occupancies.at(from: begins_at - margin, to: ends_at + margin)
              .where.not(id:).where.not(begins_at: ends_at).where.not(ends_at: begins_at)
              .where(occupancy_type: conflicting_occupancy_types, ignore_conflicting: [false, nil])
  end

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

  def to_s
    booking_string = booking.present? ? "[#{booking.ref}] " : ''
    occupiable_string = "#{id || super}@#{occupiable}: "
    range_string = "#{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)} "
    occupancy_type_string = occupancy_type

    [booking_string, occupiable_string, range_string, occupancy_type_string].join
  rescue StandardError
    super
  end
end
