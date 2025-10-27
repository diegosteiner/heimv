# frozen_string_literal: true

module Import
  class PfadiheimeImporter
    BOOKING_HEADER_MAPPING = %w[ignore.id ignore.cottage_id ignore.user_id booking.begins_at booking.ends_at
                                booking.remarks booking.occupancy_type ignore.created_at ignore.updated_at
                                tenant.email ignore.occupancy_type booking.internal_remarks ignore.slug
                                booking.headcount tenant.birth_date booking.tenant_organisation tenant.name
                                tenant.address_addon tenant.street_address tenant.zipcode tenant.city
                                tenant.phone].freeze

    def initialize(**options)
      default_options = { base_url: 'https://pfadiheime.ch', api_key: ENV.fetch('PFADIHEIME_API_KEY', nil) }
      @options = default_options.deep_merge(options)
    end

    def connection
      require 'faraday'
      @connection ||= Faraday.new(url: @options.fetch(:base_url),
                                  headers: { 'Authorization' => "Bearer #{@options.fetch(:api_key)}" })
    end

    def import_occupancies(pfadiheime_id, home)
      response = connection.get("/de/manage/cottages/#{pfadiheime_id}/occupancies.csv")
      return unless response.status == 200

      # occupancy_importer = Import::Csv::OccupancyImporter.new(home, csv: { headers: BOOKING_HEADER_MAPPING })
      # occupancy_importer.parse(response.body)

      booking_importer = Import::Csv::BookingImporter.new(home, csv: { headers: BOOKING_HEADER_MAPPING })
      booking_importer.parse(response.body)
    end
  end
end
