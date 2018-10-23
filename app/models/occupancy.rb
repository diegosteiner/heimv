class Occupancy < ApplicationRecord
  belongs_to :home
  belongs_to :booking, inverse_of: :occupancy

  date_time_attribute :begins_at, timezone: Time.zone.name
  date_time_attribute :ends_at, timezone: Time.zone.name

  # belongs_to :booking, inverse_of: :occupancy, required: false
  enum occupancy_type: %i[free tentative occupied closed]

  scope :future, -> { where(arel_table[:begins_at].gteq(Time.zone.now)) }
  scope :today, -> { at((Time.zone.now.beginning_of_day)..(Time.zone.now.end_of_day)) }
  scope :begins_at, ->(at) { where(arel_table[:begins_at].between(at)) }
  scope :ends_at, ->(at) { where(arel_table[:ends_at].between(at)) }
  scope :blocking, -> { where(occupancy_type: %i[tentative occupied closed]) }
  scope :window, ->(from = Time.zone.now.beginning_of_day, window = 18.months) { at(from..(from + window)) }
  scope :at, (lambda do |at|
    at = at.is_a?(Range) ? at : (at..at)
    where(arel_table[:begins_at].lteq(at.begin))
      .where(arel_table[:ends_at].gteq(at.end))
      .or(begins_at(at))
      .or(ends_at(at))
  end)

  validates :begins_at, :ends_at, :booking, presence: true
  validates :begins_at_date, :begins_at_time, :ends_at_date, :ends_at_time, presence: true
  validate do
    errors.add(:ends_at, :invalid) unless begins_at && ends_at && begins_at < ends_at
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
    home.occupancies.at(span)
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
