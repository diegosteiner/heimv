module Manage
  class UsageParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id booking_id used_units remarks]
    end
  end
end
