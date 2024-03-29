# frozen_string_literal: true

module Import
  module Hash
    class HomeImporter < Base
      attr_reader :organisation

      use_attributes(*%w[name description active ref occupiable home_id])

      def initialize(organisation, **options)
        super(**options)
        @organisation = organisation
      end

      def initialize_record(_hash)
        organisation.homes.build
      end
    end
  end
end
