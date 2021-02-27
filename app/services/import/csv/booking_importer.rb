# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter
      delegate :organisation, to: :home
      attr_reader :home, :options

      def initialize(home, **options)
        @home = home
        @options = options.reverse_merge({ datetime_format: '%FT%T', default_email: 'unknown@heimv.local' })
      end

      def read(input = ARGF, **options)
        Booking.transaction do
          options.reverse_merge!({ headers: true })
          result = CSV.parse(input, **options).map { import_row(_1, home.bookings.new) }
          raise ActiveRecord::Rollback, :dry_run if options[:dry_run].present?

          result
        end
      end

      def import_row(row, memo)
        self.class.actors.each_with_object(memo) do |actor_block, booking|
          instance_exec(booking, row, &actor_block)
          booking.save!
        end
      end

      def self.actor(&block)
        actors << block
      end

      def self.actors
        @actors ||= []
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
