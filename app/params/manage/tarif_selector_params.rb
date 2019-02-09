module Manage
  class TarifSelectorParams < ApplicationParams
    def self.permitted_keys
      %i[type] +
        [{ tarif_tarif_selectors_attributes: TarifTarifSelectorParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
