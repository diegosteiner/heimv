# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def self.supported_headers
        super + ['booking.ref', 'booking.remarks', 'booking.headcount', 'booking.tenant_organisation',
                 'booking.purpose', 'booking.email'] +
          OccupancyImporter.supported_headers +
          TenantImporter.supported_headers
      end

      def initialize(home, **options)
        super(**options)
        @home = home.is_a?(Home) ? home : Home.find(home)
        @tenant_importer = TenantImporter.new(organisation)
      end

      def default_options
        super.merge({
                      datetime_format: ['%FT%T', '%F %T %z'],
                      initial_state: :provisional_request
                    })
      end

      def initialize_record(_row)
        organisation.bookings.new(home: home)
      end

      def persist_record(booking)
        booking.save && booking.state_transition
      end

      actor do |booking, row|
        booking&.assign_attributes(import_data: row.to_h, editable: false,
                                   notifications_enabled: false, ref: row['booking.ref'],
                                   remarks: row['booking.remarks'],
                                   committed_request: booking.occupancy&.occupied?,
                                   approximate_headcount: row['booking.headcount']&.to_i,
                                   tenant_organisation: row['booking.tenant_organisation'])
      end

      actor :state do |booking, _row, _options|
        booking.transition_to = options[:initial_state]
      end

      actor :purpose do |booking, row, options|
        booking.purpose = organisation.booking_purposes.find_by(key: row['booking.purpose']) ||
                          options[:default_purpose]
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
          tarif = home.tarifs.find(usage_header_match[1])
          booking.usages.build(tarif: tarif, used_units: used_units) if used_units.positive?
        end
      end
    end
  end
end
