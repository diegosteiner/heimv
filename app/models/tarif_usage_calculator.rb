class TarifUsageCalculator < ApplicationRecord
  belongs_to :tarif, inverse_of: :tarif_usage_calculators
  belongs_to :usage_calculator, inverse_of: :tarif_usage_calculators
  # has_many :usages, through: :tarif

  validate do
    next if distinction.blank? || usage_calculator.class::DISTINCTION_REGEX.match(distinction)
    errors.add(:distinction, :invalid)
  end

  def usages
  end
end
