module Manage
  class TarifSelectorParams < ApplicationParams
    def self.permitted_keys
      %i[type position] +
        [{ tarif_tarif_selectors_attributes: TarifTarifSelectorParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
