# frozen_string_literal: true

module Manage
  class UsageParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id booking_id used_units remarks price_per_unit committed] +
        [{ meter_reading_period_attributes: %i[start_value end_value id _destroy] }]
    end
  end
end
