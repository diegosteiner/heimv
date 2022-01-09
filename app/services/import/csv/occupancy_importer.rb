# frozen_string_literal: true

module Import
  module Csv
    class OccupancyImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

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

      def skip_row?(row, _index)
        super || %w[declined_request].include?(row['occupancy.occupancy_type']&.downcase)
      end

      def initialize_record(_row)
        home.occupancies.new
      end

      def persist_record(occupancy)
        occupancy.booking.save && occupancy.booking.state_transition if occupancy.booking.presence
        occupancy.save
      end

      def parse_datetime(value, formats: options[:datetime_format])
        Array.wrap(formats).each do |format|
          return Time.zone.strptime(value, format)
        rescue ArgumentError => e
          Rails.logger.warn(e.message)
          nil
        end
      end

      actor do |occupancy, row|
        begins_at = row['occupancy.begins_at'] ||
                    [row['occupancy.begins_at_date'], row['occupancy.begins_at_time']].compact_blank.join('T')
        ends_at = row['occupancy.ends_at'] ||
                  [row['occupancy.ends_at_date'], row['occupancy.ends_at_time']].compact_blank.join('T')

        occupancy.assign_attributes(begins_at: parse_datetime(begins_at),
                                    ends_at: parse_datetime(ends_at),
                                    remarks: row['occupancy.remarks'])
      end

      actor do |occupancy, row|
        case row['occupancy.occupancy_type']&.downcase
        when 'closed', 'closedown', 'geschlossen'
          occupancy.occupancy_type = :closed
        when 'provisionally_reserved', 'request'
          occupancy.build_booking(home: home, organisation: organisation, committed_request: false)
        else
          occupancy.build_booking(home: home, organisation: organisation, committed_request: true)
        end
      end

      actor do |occupancy, row|
        occupancy.booking&.assign_attributes(import_data: row.to_h, editable: false,
                                             notifications_enabled: false, ref: row['booking.ref'],
                                             remarks: row['booking.remarks'],
                                             approximate_headcount: row['booking.headcount']&.to_i,
                                             tenant_organisation: row['booking.tenant_organisation'])
      end

      actor do |occupancy, _row, _options|
        next if occupancy.booking.blank?

        occupancy.booking.transition_to = options[:initial_state]
      end

      actor do |occupancy, row, options|
        next if occupancy.booking.blank?

        purpose_key = row['booking.purpose']
        occupancy.booking.purpose = organisation.booking_purposes.find_by(key: purpose_key) ||
                                    options[:default_purpose]
      end

      actor do |occupancy, row|
        next if occupancy.booking.blank?

        tenant = @tenant_importer.import_row(row)
        occupancy.booking.tenant = tenant
        occupancy.booking.email = tenant&.email || row['booking.email']
      end
    end
  end
end
