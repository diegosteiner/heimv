module Manage
  class TarifTarifSelectorParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id override distinction]
    end
  end
end
