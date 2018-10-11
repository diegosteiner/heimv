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

  scope :last_of, (lambda do |tarif|
    where(tarif: tarif).order(ends_at: :DESC).last
  end)

  def used_units
    [end_value, start_value].compact.inject(&:-).abs
  end
end
