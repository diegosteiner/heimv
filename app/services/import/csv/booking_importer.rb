# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def initialize(home, **options)
        super(options.reverse_merge({ datetime_format: '%FT%T', default_email: 'unknown@heimv.local' }))
        @home = home
      end

      actor do |booking, row|
        begins_at = Time.zone.strptime(row['begins_at'], options[:datetime_format]) + 8.hours
        ends_at = Time.zone.strptime(row['ends_at'], options[:datetime_format]) + 18.hours

        booking.occupancy = Occupancy.new(begins_at: begins_at, ends_at: ends_at)
      end

      actor do |booking, row|
        booking.assign_attributes({
                                    import_data: row.to_h, email: row['email'].presence, timeframe_locked: true,
                                    editable: false,
                                    notifications_enabled: false, transition_to: :upcoming, ref: row['ref'].presence,
                                    tenant_organisation: row['organisation'].presence, remarks: row['remarks'].presence
                                  })
      end

      actor do |booking, row|
        booking.purpose = BookingPurpose.find_by(key: row['purpose'])
      end

      actor do |booking, row|
        booking.assign_attributes(tenant_attributes: {
                                    phone: row['phone'].presence
                                  })
      end
    end
  end
end
