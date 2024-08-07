# frozen_string_literal: true

module Import
  module Hash
    class BookingCategoryImporter < Base
      attr_reader :organisation

      use_attributes(*%w[key title_i18n])

      def initialize(organisation, **)
        super(**)
        @organisation = organisation
      end

      def initialize_record(hash)
        organisation.booking_categories.find_or_initialize_by(hash.slice('key'))
      end
    end
  end
end
