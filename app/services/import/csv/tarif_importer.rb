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
        tarif_type = row.try_field('type')
        tarif_klass = tarif_type && Tarifs.const_get(tarif_type) || Tarifs::Amount
        tarif_klass.new(home: home)
      end

      actor do |tarif, row|
        tarif.assign_attributes(label: row.try_field('label', 'bezeichnung'),
                                price_per_unit: row.try_field('price', 'preis', 'price_per_unit')&.to_f || 0,
                                tarif_group: row.try_field('tarif_group', 'group', 'gruppe'),
                                unit: row.try_field('unit', 'einheit'),
                                position: row.try_field('pos', 'position')&.to_i)
      end

      actor do |tarif, row|
        invoice_type = row.try_field('invoice_type')
        tarif.invoice_type = Invoices.const_get(invoice_type) if invoice_type
      end
    end
  end
end
