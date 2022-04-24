# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id             :uuid             not null, primary key
#  begins_at      :datetime         not null
#  color          :string
#  ends_at        :datetime         not null
#  occupancy_type :integer          default("free"), not null
#  remarks        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid
#  home_id        :bigint           not null
#
# Indexes
#
#  index_occupancies_on_begins_at       (begins_at)
#  index_occupancies_on_ends_at         (ends_at)
#  index_occupancies_on_home_id         (home_id)
#  index_occupancies_on_occupancy_type  (occupancy_type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#

class Occupancy < ApplicationRecord
  COLOR_REGEX = /\A#(?:[0-9a-fA-F]{3,4}){1,2}\z/
  belongs_to :home
  belongs_to :booking, inverse_of: :occupancy, optional: true

  has_one :organisation, through: :home

  date_time_attribute :begins_at, timezone: Time.zone.name
  date_time_attribute :ends_at, timezone: Time.zone.name

  enum occupancy_type: { free: 0, tentative: 1, occupied: 2, closed: 3 }

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :future, -> { begins_at(after: Time.zone.now) }
  scope :today, ->(date = Time.zone.today) { at(from: date.beginning_of_day, to: date.end_of_day) }
  scope :blocking, -> { where(occupancy_type: %i[tentative occupied closed]) }
  scope :begins_at, (lambda do |before: nil, after: nil|
    return where(arel_table[:begins_at].between(after..before)) if before.present? && after.present?
    return where(arel_table[:begins_at].gt(after)) if after.present?
    return where(arel_table[:begins_at].lt(before)) if before.present?
  end)
  scope :ends_at, (lambda do |before: nil, after: nil|
    return where(arel_table[:ends_at].between(after..before)) if before.present? && after.present?
    return where(arel_table[:ends_at].gt(after)) if after.present?
    return where(arel_table[:ends_at].lt(before)) if before.present?
  end)
  scope :at, (lambda do |from:, to:|
    begins_at(before: from).ends_at(after: to)
    .or(begins_at(before: to, after: from))
    .or(ends_at(before: to, after: from))
  end)

  validates :color, format: { with: COLOR_REGEX }, allow_nil: true
  validates :begins_at, :ends_at, presence: true
  validates :begins_at_date, :begins_at_time, :ends_at_date, :ends_at_time, presence: true
  validate do
    errors.add(:ends_at, :invalid) unless complete? && begins_at < ends_at
  end
  validate on: %i[public_create public_update] do
    window = home.settings.booking_window
    errors.add(:begins_at, :too_far_in_past) if begins_at && begins_at < window.ago
    errors.add(:ends_at, :too_far_in_past) if ends_at && ends_at < window.ago
    errors.add(:begins_at, :too_far_in_future) if begins_at && begins_at > window.from_now
    errors.add(:ends_at, :too_far_in_future) if ends_at && ends_at > window.from_now
  end
  validate on: %i[public_create public_update] do
    acceptable_hours = (7.hours)..(22.hours)
    errors.add(:begins_at_time, :invalid) unless acceptable_hours.include?(begins_at&.seconds_since_midnight)
    errors.add(:ends_at_time, :invalid) unless acceptable_hours.include?(ends_at&.seconds_since_midnight)
  end

  def to_s
    "#{I18n.l(begins_at, format: :short)} - #{I18n.l(ends_at, format: :short)}"
  end

  def today?(date = Time.zone.today)
    ((begins_at.to_date)..(ends_at.to_date)).cover?(date)
  end

  def past?(at = Time.zone.now)
    ends_at < at
  end

  def complete?
    begins_at.present? && ends_at.present?
  end

  def overlapping(margin = 0)
    return unless complete?

    home.occupancies.at(from: begins_at - margin, to: ends_at + margin)
  end

  def conflicting(margin = 0)
    overlapping(margin)&.blocking&.where&.not(id: id)
  end

  def span
    return unless complete?

    begins_at..ends_at
  end

  def duration
    return unless complete?

    ActiveSupport::Duration.build(ends_at - begins_at)
  end

  def nights
    return unless complete?

    (ends_at.to_date - begins_at.to_date).to_i
  end

  def color=(value)
    super(value.presence) if value != color
  end

  def color
    super || booking&.color || home&.settings&.occupancy_color(self)
  end
end
