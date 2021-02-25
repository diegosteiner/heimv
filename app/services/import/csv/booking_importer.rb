# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter
      delegate :organisation, to: :home
      attr_reader :home, :options

      def initialize(home, **options)
        @home = home
        @options = options.reverse_merge({ datetime_format: '%FT%T' })
      end

      def read(input = ARGF, **options)
        Booking.transaction do
          options.reverse_merge!({ headers: true })
          result = CSV.parse(input, **options).map { import(_1) }
          raise ActiveRecord::Rollback, :dry_run if options[:dry_run].present?

          result
        end
      end

      # rubocop:disable Metrics/AbcSize
      def import(row)
        occupancy = Occupancy.new({
                                    begins_at: DateTime.strptime(row['begins_at'], options[:datetime_format]),
                                    ends_at: DateTime.strptime(row['ends_at'], options[:datetime_format])
                                  })
        home.bookings.create({
                               occupancy: occupancy, email: row['email'], import_data: row.to_h,
                               notifications_enabled: false, transition_to: :upcoming, ref: row['ref'],
                               tenant_organisation: row['organisation'], remarks: row['remarks']
                             })
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
