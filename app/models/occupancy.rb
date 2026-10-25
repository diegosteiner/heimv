# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id                 :uuid             not null, primary key
#  begins_at          :datetime         not null
#  color              :string
#  conflict_type      :integer          default("pending"), not null
#  ends_at            :datetime         not null
#  ignore_conflicting :boolean          default(FALSE), not null
#  linked             :boolean          default(TRUE)
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  calendar_label_id  :bigint
#  occupiable_id      :bigint           not null
#

class Occupancy < ApplicationRecord
  CONFLICT_TYPES = { pending: 0, tentative: 1, occupied: 2, closed: 3, free: 4, void: 6 }.freeze # internal: 5 is deprec
  CONFLICTS = {
    any: CONFLICT_TYPES.keys,
    free: [], void: [],
    pending: %i[closed],
    tentative: %i[tentative occupied closed],
    occupied: %i[tentative occupied closed],
    closed: %i[tentative occupied closed]
  }.freeze

  include Timespanable

  timespan :begins_at, :ends_at
  belongs_to :occupiable, inverse_of: :occupancies
  belongs_to :booking, inverse_of: :occupancies, optional: true, touch: true
  belongs_to :calendar_label, optional: true

  has_one :organisation, through: :occupiable

  enum :conflict_type, CONFLICT_TYPES, prefix: true

  scope :ordered, -> { order(begins_at: :ASC) }

  before_validation :sync_booking

  def default_calendar_label
    organisation&.calendar_labels&.find_by(conflict_type_default: conflict_type)
  end

  validates :conflict_type, presence: true
  validates :conflict_type, inclusion: { in: (CONFLICT_TYPES.keys - %i[closed free]).map(&:to_s) }, if: :linked
  validates_with OccupancyConflictValidator

  validate on: %i[manage_create manage_update] do
    errors.add(:begins_at, :invalid) if linked && begins_at != booking&.begins_at
    errors.add(:ends_at, :invalid) if linked && ends_at != booking&.ends_at
  end
  validate on: %i[public_create public_update agent_create agent_update] do
    errors.add(:occupiable, :invalid) unless occupiable&.occupiable && occupiable.bookable
  end
  validate do
    errors.add(:occupiable_id, :invalid) if !organisation || booking&.organisation&.!=(organisation)
    errors.add(:linked, :invalid) if linked && booking.blank?
  end
  validate do
    errors.add(:occupiable_id, :invalid) if booking.present? && occupiable&.home_id != booking.home_id
  end

  def conflict?(...)
    conflicting(...)&.exists?
  end

  def conflicting(assuming: nil, margin: nil) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    return unless begins_at.present? && ends_at.present? && occupiable.present?

    margin ||= occupiable.settings&.booking_margin || 0
    conflict_types = CONFLICTS[assuming&.to_sym || conflict_type.to_sym]

    occupiable.occupancies.at(from: begins_at - margin, to: ends_at + margin)
              .where.not(id:).where.not(begins_at: ends_at).where.not(ends_at: begins_at)
              .where(conflict_type: conflict_types, ignore_conflicting: [false, nil])
  end

  # color is used in ical too!
  def color
    # legacy
    super.presence || booking&.occupancy_color.presence ||
      # not legacy
      calendar_label&.color.presence || default_calendar_label&.color.presence
  end

  def sync_booking
    return if !linked || booking.blank?

    assign_attributes(begins_at: booking.begins_at, ends_at: booking.ends_at,
                      calendar_label: booking.calendar_label || booking.default_calendar_label,
                      conflict_type: booking.conflict_type, ignore_conflicting: booking.ignore_conflicting)
  end

  def to_s
    booking_string = booking.present? ? "[#{booking.ref}] " : ''
    occupiable_string = "#{id || super}@#{occupiable}: "
    range_string = "#{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)} "
    conflict_type_string = conflict_type

    [booking_string, occupiable_string, range_string, conflict_type_string].join
  rescue StandardError
    super
  end
end
