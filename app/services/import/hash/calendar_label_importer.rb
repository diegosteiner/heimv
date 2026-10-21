# frozen_string_literal: true

module Import
  module Hash
    class CalendarLabelImporter < Base
      attr_reader :organisation

      use_attributes(*%w[color title title_i18n description description_i18n occupancy_status_default])

      def initialize(organisation, **)
        super(**)
        @organisation = organisation
      end

      def initialize_record(hash)
        organisation.calendar_labels.find_or_initialize_by(hash.slice('color'))
      end
    end
  end
end
