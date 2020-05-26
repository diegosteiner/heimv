module Manage
  class UsageParams < ApplicationParams
    def self.permitted_keys
      %i[tarif_id booking_id presumed_used_units used_units remarks] +
        [{ meter_reading_period_attributes: MeterReadingPeriodParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
