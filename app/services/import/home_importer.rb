# frozen_string_literal: true

module Import
  class HomeImporter < Base
    def relevant_attributes
      %w[janitor min_occupation name address ref requests_allowed]
    end

    protected

    def to_h
      organisation.homes.find_each.map do |home|
        tarifs = TarifImporter.new(home, options).export
        [home.id, home.attributes.slice(*relevant_attributes).merge({ tarifs: tarifs })]
      end.to_h
    end

    def from_h(serialized)
      serialized.map do |id, attributes|
        home = organisation.homes.find_or_initialize_by(id: id)
        home.update(attributes.slice(*relevant_attributes)) if home.new_record? || options[:replace]
        home if home.valid? && from_h_tarifs(home, attributes)
      end
    end

    def from_h_tarifs(home, serialized)
      TarifImporter.new(home, options).import(serialized['tarifs'])
    end
  end
end
