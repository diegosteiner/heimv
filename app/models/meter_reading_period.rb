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

class MeterReadingPeriod < ApplicationRecord
  belongs_to :usage, optional: true
  belongs_to :tarif
  has_one :home, through: :tarif
  has_one :booking, through: :usage
  has_one :organisation, through: :tarif

  scope :ordered, -> { order(ends_at: :asc) }

  validates :start_value, :end_value, numericality: true, allow_nil: true

  before_validation do
    self.begins_at ||= booking&.begins_at
    self.ends_at ||= booking&.ends_at
    self.tarif ||= usage&.tarif
    infer_start_value
  end

  def infer_start_value
    self.start_value ||= self.class.where(tarif:).where.not(id:)
                             .where(self.class.arel_table[:ends_at].lteq(begins_at)).ordered.last&.end_value
  end

  def used_units
    return nil unless end_value.present? && start_value.present?

    (end_value - start_value).abs
  end

  class Filter < ApplicationFilter
    attribute :begins_at_after, :datetime
    attribute :begins_at_before, :datetime
    attribute :ends_at_after, :datetime
    attribute :ends_at_before, :datetime
    attribute :tarif_ids, default: -> { [] }
    attribute :occupiable_ids, default: -> { [] }

    def tarif_ids=(value)
      super(Array.wrap(value).flatten.compact_blank)
    end

    def occupiable_ids=(value)
      super(Array.wrap(value).flatten.compact_blank)
    end

    filter :tarifs do |meter_reading_periods|
      meter_reading_periods.where(tarif_id: tarif_ids) if tarif_ids.present?
    end

    filter :occupiables do |meter_reading_periods|
      next if occupiable_ids.blank?

      meter_reading_periods.joins(usage: { booking: :occupancies })
                           .where(usages: { bookings: { occupancies: { occupiable_id: occupiable_ids } } })
    end

    filter :begins_at do |meter_reading_periods|
      next meter_reading_periods unless begins_at_after || begins_at_before

      begins_at = MeterReadingPeriod.arel_table[:begins_at]

      next meter_reading_periods.where(begins_at.gteq(begins_at_after)) if begins_at_after && !begins_at_before
      next meter_reading_periods.where(begins_at.lteq(begins_at_before)) if !begins_at_after && begins_at_before

      next meter_reading_periods.where(begins_at.between(begins_at_after..begins_at_before))
    end

    filter :ends_at do |meter_reading_periods|
      next meter_reading_periods unless ends_at_after || ends_at_before

      ends_at = MeterReadingPeriod.arel_table[:ends_at]

      next meter_reading_periods.where(ends_at.gteq(ends_at_after)) if ends_at_after && !ends_at_before
      next meter_reading_periods.where(ends_at.lteq(ends_at_before)) if !ends_at_after && ends_at_before

      next meter_reading_periods.where(ends_at.between(ends_at_after..ends_at_before))
    end
  end
end
