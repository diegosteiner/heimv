module Manage
  class UsageParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id booking_id used_units remarks meter_starts_at meter_ends_at]
    end
  end
end
