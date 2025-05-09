# frozen_string_literal: true

module Import
  module Hash
    class HomeImporter < Base
      attr_reader :organisation

      use_attributes(*%w[name description discarded_at ref occupiable home_id occupiable_settings])

      def initialize(organisation, **)
        super(**)
        @organisation = organisation
      end

      def initialize_record(_hash)
        organisation.homes.build
      end
    end
  end
end
