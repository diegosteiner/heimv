module Manage
  class UsageCalculatorParams < ApplicationParams
    def self.permitted_keys
      %i[type] +
        [{ tarif_usage_calculators_attributes: TarifUsageCalculatorParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
