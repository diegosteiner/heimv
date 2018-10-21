module Tarifs
  class Metered < Tarif
    module UsageDecorator
      extend ActiveSupport::Concern

      included do
        has_one :meter_reading_period, dependent: :nullify

        accepts_nested_attributes_for :meter_reading_period, reject_if: :all_blank

        before_save do
          self.used_units ||= meter_reading_period&.used_units
        end
      end

      def build_meter_reading_period(attrs = {})
        super(attrs).tap do |meter_reading_period|
          meter_reading_period.start_value ||= MeterReadingPeriod.where(tarif: tarif.original)
                                                                 .ordered&.last&.start_value
        end
      end
    end
  end
end
