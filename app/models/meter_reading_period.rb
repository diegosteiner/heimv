# frozen_string_literal: true

# == Schema Information
#
# Table name: meter_reading_periods
#
#  id          :bigint           not null, primary key
#  begins_at   :datetime
#  end_value   :decimal(, )
#  ends_at     :datetime
#  start_value :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#  usage_id    :bigint
#
# Indexes
#
#  index_meter_reading_periods_on_tarif_id  (tarif_id)
#  index_meter_reading_periods_on_usage_id  (usage_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#  fk_rails_...  (usage_id => usages.id)
#

class MeterReadingPeriod < ApplicationRecord
  belongs_to :usage, optional: true
  belongs_to :tarif
  has_one :home, through: :tarif
  has_one :booking, through: :usage

  scope :ordered, -> { order(ends_at: :asc) }

  validates :start_value, :end_value, numericality: true, allow_nil: true
  validates :begins_at, :ends_at, presence: true

  before_validation do
    self.begins_at ||= booking&.occupancy&.begins_at
    self.ends_at ||= booking&.occupancy&.ends_at
    self.tarif ||= usage&.tarif&.original
  end

  def used_units
    return nil unless end_value.present? && start_value.present?

    (end_value - start_value).abs
  end
end
