# frozen_string_literal: true

module Import
  class TarifImporter < Base
    attr_reader :home

    def initialize(home, options = {})
      super(home.organisation, **options)
      @home = home
    end

    def relevant_attributes
      %w[invoice_type label meter position prefill_usage_method price_per_unit tarif_group transient type unit
         valid_from valid_until]
    end

    protected

    def to_h
      home.tarifs.find_each.map do |tarif|
        [tarif.id, tarif.attributes.slice(*relevant_attributes)]
      end.to_h
    end

    def from_h(serialized)
      serialized.map do |id, attributes|
        tarif = home.tarifs.find_or_initialize_by(id: id)
        tarif.update(attributes.slice(*relevant_attributes)) if tarif.new_record? || options[:replace]
        tarif if tarif.valid?
      end
    end
  end
end
