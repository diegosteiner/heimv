require_relative './base_seeder'

module Seeders
  class BookingSeeder < BaseSeeder
    def seed_development
      {
        requests: seeds[:homes].map { |home| create_list(:booking, 1, initial_state: :new_request, home: home) },
        bookings: seeds[:homes].map { |home| create_list(:booking, 3, initial_state: :confirmed_new_request, home: home) }
      }
    end
  end
end
