require_relative './base_seeder'

module Seeders
  class BookingSeeder < BaseSeeder
    def seed_development
      {
        requests: seeds[:homes].map { |home| create_list(:booking, 10, initial_state: :new_request, home: home) }
      }
    end
  end
end
