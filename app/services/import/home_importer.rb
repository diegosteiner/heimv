# frozen_string_literal: true

module Import
  class HomeImporter < Base
    def relevant_attributes
      %w[janitor min_occupation name address ref requests_allowed]
    end

    protected

    def _export
      organisation.homes.find_each.map do |home|
        tarifs = TarifImporter.new(home, options).export
        [home.id, home.attributes.slice(*relevant_attributes).merge({ tarifs: tarifs })]
      end.to_h
    end

    def _import(serialized)
      serialized.map do |id, attributes|
        home = organisation.homes.find_or_initialize_by(id: id)
        home.update(attributes.slice(*relevant_attributes)) if home.new_record? || options[:replace]
        home if home.valid? && _import_tarifs(home, attributes)
      end
    end

    def _import_tarifs(home, serialized)
      TarifImporter.new(home, options).import(serialized['tarifs'])
    end
  end
end
