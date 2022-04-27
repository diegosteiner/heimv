# frozen_string_literal: true

module Import
  class PfadiheimeImporter
    OCCUPANCY_HEADER_MAPPING = %w[ignore.id ignore.cottage_id ignore.user_id occupancy.begins_at occupancy.ends_at
                                  occupancy.remarks occupancy.occupancy_type ignore.created_at ignore.updated_at
                                  tenant.email ignore.occupancy_type booking.remarks ignore.slug booking.headcount
                                  tenant.birth_date booking.tenant_organisation tenant.name tenant.street_address
                                  tenant.street_address_2 tenant.zipcode tenant.city tenant.phone].freeze

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

      occupancy_importer = Import::Csv::OccupancyImporter.new(home, csv: { headers: OCCUPANCY_HEADER_MAPPING })
      occupancy_importer.parse(response.body)
    end
  end
end
