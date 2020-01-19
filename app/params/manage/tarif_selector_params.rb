module Manage
  class TarifSelectorParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id type veto distinction]
    end
  end
end
