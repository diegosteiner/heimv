# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def initialize(home, **options)
        super(options.reverse_merge({ datetime_format: '%FT%T', default_email: 'unknown@heimv.local' }))
        @home = home
        @tenant_importer = TenantImporter.new(organisation)
      end

      def initialize_record(_row)
        organisation.bookings.new(home: home)
      end

      actor do |booking, row|
        begins_at = Time.zone.strptime(row['begins_at'], options[:datetime_format])
        ends_at = Time.zone.strptime(row['ends_at'], options[:datetime_format])

        booking.build_occupancy(begins_at: begins_at, ends_at: ends_at, organisation: organisation)
      end

      actor do |booking, row|
        booking.assign_attributes(import_data: row.to_h, timeframe_locked: true, editable: false,
                                  notifications_enabled: false, transition_to: :upcoming, ref: row['ref'].presence,
                                  tenant_organisation: row['organisation'].presence, remarks: row['remarks'].presence)
      end

      actor do |booking, row|
        booking.purpose = organisation.booking_purposes.find_by(key: row['purpose'])
      end

      actor do |booking, row|
        booking.tenant = @tenant_importer.import_row(row)
        booking.email = booking.tenant&.email
      end
    end
  end
end
