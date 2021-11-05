# frozen_string_literal: true

module Import
  module Hash
    class TarifImporter < Base
      attr_reader :home

      use_attributes(*%w[invoice_type label_i18n meter ordinal prefill_usage_method price_per_unit tarif_group
                         transient type unit_i18n valid_from valid_until tenant_visible])

      def initialize(home, **options)
        super(**options)
        @home = home
      end

      def initialize_record(_hash)
        home.tarifs.build
      end
    end
  end
end
