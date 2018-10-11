module Tarifs
  class Metered < Tarif
    # def meter_reading_period(usage)
    #   MeterReadingPeriod.find_or_initialize_by(booking: usage.booking, tarif: usage.tarif) do |meter_reading|

    #   end
    # end

    module UsageDecorator
      extend ActiveSupport::Concern

      included do
        has_one :meter_reading_period

        accepts_nested_attributes_for :meter_reading_period, reject_if: :all_blank

        before_save do
          self.used_units ||= meter_reading_period&.used_units
        end
      end
    end
  end
end
