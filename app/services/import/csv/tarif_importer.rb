# frozen_string_literal: true

module Import
  module Csv
    class TarifImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def initialize(home, **options)
        super(**options)
        @home = home
      end

      def initialize_record(row)
        tarif_type = row['tarif.type']
        tarif_klass = (tarif_type && Tarifs.const_get(tarif_type)) || Tarifs::Amount
        tarif_klass.new(home: home)
      end

      actor do |tarif, row|
        tarif.assign_attributes(label: row['tarif.label'],
                                price_per_unit: row['tarif.price']&.to_f || 0,
                                tarif_group: row['tarif.tarif_group'],
                                unit: row['tarif.unit'],
                                ordinal: row['tarif.ordinal']&.to_i)
      end

      actor do |tarif, row|
        invoice_type = row['tarif.invoice_type']
        tarif.invoice_type = Invoices.const_get(invoice_type) if invoice_type
      end
    end
  end
end
