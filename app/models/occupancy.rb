# == Schema Information
#
# Table name: occupancies
#
#  id             :uuid             not null, primary key
#  begins_at      :datetime         not null
#  booking_type   :string
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
#  index_occupancies_on_begins_at                    (begins_at)
#  index_occupancies_on_booking_type_and_booking_id  (booking_type,booking_id)
#  index_occupancies_on_ends_at                      (ends_at)
#  index_occupancies_on_home_id                      (home_id)
#  index_occupancies_on_occupancy_type               (occupancy_type)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#

class Occupancy < ApplicationRecord
  belongs_to :home
  belongs_to :booking, inverse_of: :occupancy, optional: true

  date_time_attribute :begins_at, timezone: Time.zone.name
  date_time_attribute :ends_at, timezone: Time.zone.name

  enum occupancy_type: { free: 0, tentative: 1, occupied: 2, closed: 3 }

  scope :future, -> { begins_at(after: Time.zone.now) }
  scope :today, ->(date = Time.zone.today) { at(from: date.beginning_of_day, to: date.end_of_day) }
  scope :blocking, -> { where(occupancy_type: %i[tentative occupied closed]) }
  scope :window, ->(from = Time.zone.now.beginning_of_day, window = 18.months) { at(from: from, to: (from + window)) }
  scope :begins_at, (lambda do |before: nil, after: nil|
    return where(arel_table[:begins_at].between(after..before)) if before.present? && after.present?
    return where(arel_table[:begins_at].gteq(after)) if after.present?
    return where(arel_table[:begins_at].lteq(before)) if before.present?
  end)
  scope :ends_at, (lambda do |before: nil, after: nil|
    return where(arel_table[:ends_at].between(after..before)) if before.present? && after.present?
    return where(arel_table[:ends_at].gteq(after)) if after.present?
    return where(arel_table[:ends_at].lteq(before)) if before.present?
  end)
  scope :at, (lambda do |from:, to:|
    begins_at(before: from).ends_at(after: to)
    .or(begins_at(before: to, after: from))
    .or(ends_at(before: to, after: from))
  end)

  validates :begins_at, :ends_at, :booking, presence: true
  validates :begins_at_date, :begins_at_time, :ends_at_date, :ends_at_time, presence: true
  validate do
    unless begins_at && ends_at && begins_at < ends_at && ends_at < 18.months.from_now
      errors.add(:ends_at, :invalid)
      errors.add(:ends_at_date, :invalid)
      errors.add(:ends_at_time, :invalid)
    end
  end
  validate on: :public_create do
    acceptable_hours = (7.hours)..(22.hours)
    errors.add(:begins_at_time, :invalid) unless acceptable_hours.include?(begins_at.seconds_since_midnight)
    errors.add(:ends_at_time, :invalid) unless acceptable_hours.include?(ends_at.seconds_since_midnight)
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

  def overlapping
    home.occupancies.at(from: begins_at, to: ends_at)
  end

  def conflicting
    overlapping.blocking.where.not(id: id)
  end

  def span
    begins_at..ends_at
  end

  def nights
    (ends_at.to_date - begins_at.to_date).to_i
  end

  delegate :ref, to: :home
end
