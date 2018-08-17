class UsageCalculator < ApplicationRecord
  DISTINCTIONS = {}.freeze

  belongs_to :home, inverse_of: :usage_calculators
  has_many :tarif_usage_calculators, dependent: :destroy, inverse_of: :usage_calculator
  has_many :tarifs, through: :tarif_usage_calculators

  accepts_nested_attributes_for :tarif_usage_calculators

  def build_tarif_usage_calculators
    self.class::DISTINCTION_PROCS.keys.map do |distinction|
      tarif_usage_calculators.build(distinction: distinction)
    end
  end

  def apply(booking, usages = booking.usages)
    tarif_usage_calculators.map do |tarif_usage_calculator|
      next unless usage = usages.find do |usage|
        tarif_usage_calculator.tarif.self_and_booking_copies(booking).include?(usage.tarif)
      end
      self.class::DISTINCTION_PROCS[tarif_usage_calculator.distinction].try(:call, usage)
    end
  end
end
