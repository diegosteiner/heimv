# frozen_string_literal: true

module Import
  module Csv
    class OccupancyImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def initialize(home_id)
        super()
        @home = home_id.is_a?(Home) ? home_id : Home.find(home)
        @tenant_importer = TenantImporter.new(organisation)
      end

      def initialize_record(row)
        return if %i[declined_request].include?(row.try_field('reservation_type', 'occupancy_type')&.downcase)

        home.occupancies.new
      end

      def default_options
        super.merge(datetime_format: ['%FT%T', '%F %T %z'])
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
        begins_at = parse_datetime(row.try_field('begins_at', 'start_date'))
        ends_at = parse_datetime(row.try_field('ends_at', 'end_date'))
        remarks = row.try_field('remarks')

        occupancy.assign_attributes(begins_at: begins_at, ends_at: ends_at, remarks: remarks)
      end

      actor do |occupancy, row|
        case row.try_field('reservation_type', 'occupancy_type')&.downcase
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
                                             notifications_enabled: false, ref: row.try_field('ref'),
                                             remarks: row.try_all_fields('remarks', 'purpose_text').join('. '),
                                             approximate_headcount: row.try_field('headcount')&.to_i,
                                             tenant_organisation: row.try_field('organisation'))
      end

      actor do |occupancy, _row, _options|
        next if occupancy.booking.blank?

        occupancy.booking.transition_to = options[:initial_state] || :provisional_request
      end

      actor do |occupancy, row, options|
        next if occupancy.booking.blank?

        purpose_key = row.try_field('purpose', 'occupancy_type')
        occupancy.booking.purpose = organisation.booking_purposes.find_by(key: purpose_key) ||
                                    options[:default_purpose]
      end

      actor do |occupancy, row|
        next if occupancy.booking.blank?

        tenant = @tenant_importer.import_row(row)
        occupancy.booking.tenant = tenant
        occupancy.booking.email = tenant&.email
      end
    end
  end
end
