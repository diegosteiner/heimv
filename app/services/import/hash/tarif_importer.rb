# frozen_string_literal: true

module Import
  module Hash
    class TarifImporter < Base
      attr_reader :organisation

      use_attributes(*%w[associated_types label_i18n ordinal prefill_usage_method price_per_unit tarif_group
                         pin type unit_i18n valid_from valid_until minimum_usage_per_night minimum_usage_total])

      def initialize(organisation, **)
        super(**)
        @organisation = organisation
      end

      def initialize_record(_hash)
        organisation.tarifs.build
      end
    end
  end
end
