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

class Occupancy < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  OCCUPANCY_TYPES = { free: 0, tentative: 1, occupied: 2, closed: 3 }.freeze

  include Timespanable

  timespan :begins_at, :ends_at
  belongs_to :occupiable, inverse_of: :occupancies
  belongs_to :booking, inverse_of: :occupancies, optional: true, touch: true

  has_one :organisation, through: :occupiable

  enum :occupancy_type, OCCUPANCY_TYPES

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :occupancy_calendar, lambda {
    where.not(occupancy_type: :free)
         .or(where(occupancy_type: :free, booking: nil))
         .left_outer_joins(:booking).where(booking: { concluded: [false, nil] })
  }

  before_validation :update_from_booking
  validates :occupancy_type, presence: true
  validates :color, format: { with: COLOR_REGEX }, allow_blank: true
  validate on: %i[public_create public_update agent_booking manage_create manage_update] do
    errors.add(:base, :occupancy_conflict) if !ignore_conflicting && conflicting?
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

  def to_s
    booking_string = booking.present? ? "[#{booking.ref}] " : ''
    occupiable_string = "@#{occupiable}: "
    range_string = "#{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)} "
    occupancy_type_string = occupancy_type

    [booking_string, occupiable_string, range_string, occupancy_type_string].join
  rescue StandardError
    super
  end

  def conflicting(conflicting_occupancy_types = %i[occupied closed], margin: occupiable&.settings&.booking_margin || 0)
    return unless valid?

    occupiable.occupancies.at(from: begins_at - margin - 1, to: ends_at + margin + 1)
              .where(occupancy_type: conflicting_occupancy_types).where.not(id:)
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
end
