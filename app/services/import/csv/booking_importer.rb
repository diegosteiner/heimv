# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def self.supported_headers
        super + ['booking.ref', 'booking.remarks', 'booking.headcount', 'booking.tenant_organisation',
                 'booking.category', 'booking.purpose', 'booking.email', 'usage.*'] +
          OccupancyImporter.supported_headers +
          TenantImporter.supported_headers
      end

      def initialize(home, **options)
        super(**options)
        @home = home.is_a?(Home) ? home : Home.find(home)
        @tenant_importer = TenantImporter.new(organisation)
      end

      def initialize_record(_row)
        organisation.bookings.new(homes: [home])
      end

      def initial_state
        state = options[:initial_state]
        return state if state && organisation.booking_flow_class.successors['initial'].include?(state.to_s)

        :open_request
      end

      def persist_record(booking)
        booking.transition_to ||= initial_state
        booking.save
      end

      actor do |booking, row|
        booking&.assign_attributes(import_data: row.to_h, editable: false,
                                   notifications_enabled: false, ref: row['booking.ref'],
                                   remarks: row['booking.remarks'], purpose_description: row['booking.purpose'],
                                   approximate_headcount: row['booking.headcount']&.to_i,
                                   tenant_organisation: row['booking.tenant_organisation'])
      end

      actor :state do |booking, _row, _options|
        booking.occupancy_type = booking.occupancies.map(&:occupancy_type).max
        booking.committed_request ||= booking.occupied?
      end

      actor :category do |booking, row, options|
        booking.category = organisation.booking_categories.find_by(key: row['booking.category']) ||
                           options[:default_category]
      end

      actor :tenant do |booking, row|
        tenant = @tenant_importer.import_row(row)
        booking.tenant = tenant
        booking.email = tenant&.email || row['booking.email']
      end

      actor :usages do |booking, row|
        row.each do |header, value|
          usage_header_match = /^usage\.(\d+)/.match(header)
          next unless usage_header_match && value.present?

          used_units = value&.to_d
          tarif = organisation.tarifs.find_by(id: usage_header_match[1])
          booking.usages.build(tarif: tarif, used_units: used_units) if tarif.present? && used_units.positive?
        end
      end
    end
  end
end
