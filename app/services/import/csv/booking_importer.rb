# frozen_string_literal: true

module Import
  module Csv
    class BookingImporter < Base
      delegate :organisation, to: :home
      attr_reader :home

      def self.supported_headers
        super + ['booking.ref', 'booking.remarks', 'booking.headcount', 'booking.tenant_organisation',
                 'booking.category', 'booking.purpose', 'booking.email', 'usage.*', 'booking.occupiable_ids',
                 'booking.internal_remarks', 'booking.begins_at', 'booking.begins_at_date', 'booking.begins_at_time',
                 'booking.ends_at', 'booking.ends_at_date', 'booking.ends_at_time', 'booking.remarks',
                 'booking.occupancy_type', 'booking.color', 'booking.transition_to', 'extra.*'] +
          TenantImporter.supported_headers
      end

      def default_options
        super.merge({ datetime_format: ['%FT%T', '%F %T %z', '%FT%H:%M', '%d.%m.%YT%H:%M'] })
      end

      def initialize(home, **options)
        super(**options)
        @home = home.is_a?(Home) ? home : Home.find(home)
        @tenant_importer = TenantImporter.new(organisation)
      end

      def initialize_record(_row)
        organisation.bookings.new(home: home)
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

      def skip_row?(row, _index)
        super || %w[declined_request closed cancelled_request].include?(row['booking.occupancy_type']&.downcase)
      end

      def parse_datetime(value, formats: options[:datetime_format])
        Array.wrap(formats).each do |format|
          return Time.zone.strptime(value, format)
        rescue ArgumentError => e
          Rails.logger.warn(e.message)
        end
        nil
      end

      actor :occupancies do |booking, row|
        begins_at = row['booking.begins_at'] ||
                    [row['booking.begins_at_date'], row['booking.begins_at_time']].compact_blank.join('T')
        ends_at = row['booking.ends_at'] ||
                  [row['booking.ends_at_date'], row['booking.ends_at_time']].compact_blank.join('T')
        occupiable_ids = row['booking.occupiable_ids']&.split(',')&.compact_blank || home.id

        booking.assign_attributes(begins_at: parse_datetime(begins_at), ends_at: parse_datetime(ends_at),
                                  occupiable_ids: occupiable_ids)
      end

      actor :occupancy_type do |booking, row|
        booking.occupancy_type = case row['booking.occupancy_type']&.downcase
                                 when 'closed', 'closedown', 'geschlossen'
                                   :closed
                                 when 'provisionally_reserved', 'request'
                                   :tentative
                                 when 'declined_request'
                                   :free
                                 else
                                   :occupied
                                 end
        booking.committed_request ||= booking.occupied?
        booking.transition_to ||= row['booking.transition_to']&.split(',')&.compact_blank&.presence
      end

      actor do |booking, row|
        booking&.assign_attributes(import_data: row.to_h, editable: false, ignore_conflicting: false,
                                   notifications_enabled: false, ref: row['booking.ref'],
                                   remarks: row['booking.remarks'], purpose_description: row['booking.purpose'],
                                   internal_remarks: row['booking.internal_remarks'],
                                   approximate_headcount: row['booking.headcount']&.to_i,
                                   tenant_organisation: row['booking.tenant_organisation'])
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

      actor :extras do |booking, row|
        row.each do |header, value|
          extra_header_match = /^extra\.(\d+)/.match(header)
          value = ActiveModel::Type::Boolean.new.cast(value)
          next unless extra_header_match && value

          bookable_extra = organisation.bookable_extras.find_by(id: extra_header_match[1])
          booking.bookable_extras << bookable_extra if bookable_extra.present?
        end
      end
    end
  end
end
