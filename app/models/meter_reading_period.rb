class MeterReadingPeriod < ApplicationRecord
  belongs_to :usage, optional: true
  belongs_to :tarif
  has_one :home, through: :tarif
  has_one :booking, through: :usage

  validates :start_value, :end_value, numericality: true, allow_nil: true
  validates :begins_at, :ends_at, presence: true

  before_validation do
    self.begins_at ||= booking&.occupancy&.begins_at
    self.ends_at ||= booking&.occupancy&.ends_at
    self.tarif ||= usage&.tarif&.original
  end

  scope :ordered, -> { order(ends_at: :ASC) }

  def used_units
    return nil unless end_value.present? && start_value.present?
    (end_value - start_value).abs
  end
end
