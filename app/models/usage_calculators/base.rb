module UsageCalculators
  class Base < ApplicationRecord
    belongs_to :home
    has_many :tarif_usage_calculators, dependent: :destroy, inverse_of: :usage_calculator
    has_many :tarifs, through: :tarif_usage_calculators

    self.abstract_class = true
    self.table_name = :'usage_calculators'
  end
end
