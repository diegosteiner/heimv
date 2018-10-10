module Tarifs
  class Metered < Tarif
    module UsageDecorator
      extend ActiveSupport::Concern

      included do
        validates :meter_starts_at, :meter_ends_at, presence: true
        after_save do
        end

        before_save do
          self.used_units = (meter_ends_at.to_f - meter_starts_at.to_f).abs
        end
      end

      def meter_starts_at
        data['meter_starts_at']
      end

      def meter_starts_at=(value)
        data['meter_starts_at'] = value
      end

      def meter_ends_at
        data['meter_ends_at']
      end

      def meter_ends_at=(value)
        data['meter_ends_at'] = value
      end
    end
  end
end
