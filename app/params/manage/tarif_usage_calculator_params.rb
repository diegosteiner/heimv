module Manage
  class TarifUsageCalculatorParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id perform_select perform_calculate distinction]
    end
  end
end
