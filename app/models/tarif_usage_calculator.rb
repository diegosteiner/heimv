  class TarifUsageCalculator < ApplicationRecord
    belongs_to :tarif, inverse_of: :tarif_usage_calculators
    belongs_to :usage_calculator, inverse_of: :tarif_usage_calculators, class_name: 'UsageCalculators::Base'

  end
