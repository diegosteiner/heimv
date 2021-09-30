# frozen_string_literal: true

module Import
  module Hash
    class HomeImporter < Base
      attr_reader :organisation

      use_attributes(*%w[janitor min_occupation name address requests_allowed])

      def initialize(organisation, **options)
        super(**options)
        @organisation = organisation
      end

      def initialize_record(_hash)
        organisation.homes.build
      end

      actor do |home, hash|
        next unless hash['tarifs'].respond_to?(:each)

        importer = TarifImporter.new(home, **options)
        hash['tarifs'].each { |tarif| home.tarifs << importer.import(tarif) }
      end
    end
  end
end
