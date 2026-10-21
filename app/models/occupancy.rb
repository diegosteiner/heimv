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
#  occupancy_status   :integer          default("pending"), not null
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  calendar_label_id  :bigint
#  occupiable_id      :bigint           not null
#

class Occupancy < ApplicationRecord
  STATUSES = { pending: 0, tentative: 1, occupied: 2, closed: 3, free: 4, internal: 5, void: 6 }.freeze
  STATUS_CONFLICTS = {
    any: STATUSES.keys,
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
  has_one :default_calendar_label, class_name: 'CalendarLabel', primary_key: :occupancy_status, # rubocop:disable Rails/HasManyOrHasOneDependent,Rails/InverseOf
                                   foreign_key: :occupancy_status_default

  enum :occupancy_status, STATUSES, prefix: :status

  scope :ordered, -> { order(begins_at: :ASC) }

  before_validation :sync_booking
  validates :occupancy_status, presence: true
  validates :occupancy_status, inclusion: { in: (STATUSES.keys - %i[closed free]).map(&:to_s) }, if: :linked
  validate do
    next if ignore_conflicting || validation_context == :ignore_conflicting

    errors.add(:base, :occupancy_conflict) if conflicting?
  end
  validate on: %i[manage_create manage_update] do
    errors.add(:begins_at, :invalid) if linked && begins_at != booking&.begins_at
    errors.add(:ends_at, :invalid) if linked && ends_at != booking&.ends_at
  end
  validate on: %i[public_create public_update] do
    errors.add(:occupiable, :invalid) unless occupiable&.occupiable
  end
  validate do
    errors.add(:occupiable_id, :invalid) if !organisation || booking&.organisation&.!=(organisation)
    errors.add(:linked, :invalid) if linked && booking.blank?
  end
  validate do
    errors.add(:occupiable_id, :invalid) if booking.present? && occupiable&.home_id != booking.home_id
  end

  def conflicting?(...)
    conflicting(...)&.exists?
  end

  def conflicting(assuming: nil, margin: nil) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    return unless begins_at.present? && ends_at.present? && occupiable.present?

    margin ||= occupiable.settings&.booking_margin || 0
    occupancy_statuses = STATUS_CONFLICTS[assuming&.to_sym || occupancy_status.to_sym]

    occupiable.occupancies.at(from: begins_at - margin, to: ends_at + margin)
              .where.not(id:).where.not(begins_at: ends_at).where.not(ends_at: begins_at)
              .where(occupancy_status: occupancy_statuses, ignore_conflicting: [false, nil])
  end

  def color
    # legacy
    super.presence || booking&.occupancy_color ||
      # not legacy
      calendar_label&.color || default_calendar_label&.color
  end

  def sync_booking
    return if !linked || booking.blank?

    assign_attributes(begins_at: booking.begins_at, ends_at: booking.ends_at, calendar_label: booking.calendar_label,
                      occupancy_status: booking.occupancy_status, ignore_conflicting: booking.ignore_conflicting)
  end

  def to_s
    booking_string = booking.present? ? "[#{booking.ref}] " : ''
    occupiable_string = "#{id || super}@#{occupiable}: "
    range_string = "#{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)} "
    occupancy_status_string = occupancy_status

    [booking_string, occupiable_string, range_string, occupancy_status_string].join
  rescue StandardError
    super
  end
end
