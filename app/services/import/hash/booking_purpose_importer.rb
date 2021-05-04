# frozen_string_literal: true

module Import
  module Hash
    class BookingPurposeImporter < Base
      attr_reader :organisation

      use_attributes(*%w[key title_i18n])

      def initialize(organisation, **options)
        super(options)
        @organisation = organisation
      end

      def initialize_record(hash)
        organisation.booking_purposes.find_or_initialize_by(hash.slice('key'))
      end
    end
  end
end
