# frozen_string_literal: true

module Import
  module Csv
    class OccupancyImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def self.supported_headers
        super + ['occupancy.begins_at', 'occupancy.begins_at_date', 'occupancy.begins_at_time', 'occupancy.ends_at',
                 'occupancy.ends_at_date', 'occupancy.ends_at_time', 'occupancy.remarks', 'occupancy.occupancy_type']
      end

      def initialize(home, **options)
        super(**options)
        @home = home.is_a?(Home) ? home : Home.find(home)
        @booking_importer = BookingImporter.new(home, **options)
      end

      def default_options
        super.merge({ datetime_format: ['%FT%T', '%F %T %z', '%FT%H:%M'] })
      end

      def initialize_record(_row)
        home.occupancies.new
      end

      def persist_record(occupancy)
        @booking_importer.persist_record(occupancy.booking) if occupancy.booking.present?
        occupancy.save
      end

      def skip_row?(row, _index)
        super || %w[declined_request].include?(row['occupancy.occupancy_type']&.downcase)
      end

      def parse_datetime(value, formats: options[:datetime_format])
        Array.wrap(formats).each do |format|
          return Time.zone.strptime(value, format)
        rescue ArgumentError => e
          Rails.logger.warn(e.message)
        end
        nil
      end

      actor :timespan do |occupancy, row|
        begins_at = row['occupancy.begins_at'] ||
                    [row['occupancy.begins_at_date'], row['occupancy.begins_at_time']].compact_blank.join('T')
        ends_at = row['occupancy.ends_at'] ||
                  [row['occupancy.ends_at_date'], row['occupancy.ends_at_time']].compact_blank.join('T')

        occupancy.assign_attributes(begins_at: parse_datetime(begins_at),
                                    ends_at: parse_datetime(ends_at))
      end

      actor :occupancy_type do |occupancy, row|
        occupancy&.occupancy_type = case row['occupancy.occupancy_type']&.downcase
                                    when 'closed', 'closedown', 'geschlossen'
                                      :closed
                                    when 'provisionally_reserved', 'request'
                                      :tentative
                                    when 'declined_request'
                                      :free
                                    else
                                      :occupied
                                    end
      end

      actor :booking do |occupancy, row|
        next unless occupancy.tentative? || occupancy.occupied?

        booking = organisation.bookings.new(occupancies: [occupancy], home: home,
                                            begins_at: occupancy.begins_at, ends_at: occupancy.ends_at)
        @booking_importer.import_row(row, initial: booking)
      end
    end
  end
end
