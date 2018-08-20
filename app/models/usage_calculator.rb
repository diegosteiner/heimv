class UsageCalculator < ApplicationRecord
  DISTINCTION_REGEX = %r(\A\w*\z)

  belongs_to :home, inverse_of: :usage_calculators
  has_many :tarif_usage_calculators, dependent: :destroy, inverse_of: :usage_calculator
  has_many :tarifs, through: :tarif_usage_calculators

  accepts_nested_attributes_for :tarif_usage_calculators

  def calculate(booking, usages = booking.usages)
    tarif_usage_calculators.map do |tarif_usage_calculator|
      # usage = usages.of_tarif(tarif_usage_calculator.tarif).where(booking: booking).first
      usage = usages.find { |u| u.of_tarif?(tarif_usage_calculator.tarif) }
      # binding.pry if tarif_usage_calculator.tarif_id == 35
      next unless usage
      calculate_apply(usage, tarif_usage_calculator.distinction)
      calculate_used_units(usage, tarif_usage_calculator.distinction)
    end
  end

  # def matching_tarif_usage_calculators(tarif_usage_calculators, &block)
    # tarif_usage_calculators.map do |tarif_usage_calculator|


    # distinction_match =
  # end

  def calculate_apply(_usage, _distinction); end
  def calculate_used_units(_usage, _distinction); end
end
