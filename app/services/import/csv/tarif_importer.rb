# frozen_string_literal: true

module Import
  module Csv
    class TarifImporter < Base
      attr_reader :organisation

      def initialize(organisation, **)
        super(**)
        @organisation = organisation
      end

      def initialize_record(row)
        tarif_type = row['tarif.type']
        tarif_klass = (tarif_type && Tarifs.const_get(tarif_type)) || Tarifs::Amount
        tarif_klass.new(organisation:)
      end

      actor do |tarif, row|
        tarif.assign_attributes(label: row['tarif.label'],
                                price_per_unit: row['tarif.price']&.to_f || 0,
                                tarif_group: row['tarif.tarif_group'],
                                unit: row['tarif.unit'],
                                ordinal: row['tarif.ordinal']&.to_i)
      end

      actor do |tarif, row|
        # TODO: check
        # tarif[:associated_types] = row['tarif.invoice_type']
      end
    end
  end
end
