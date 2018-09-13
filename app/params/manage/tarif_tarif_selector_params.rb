module Manage
  class TarifTarifSelectorParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id veto distinction]
    end
  end
end
