require_relative './base_seeder'

module Seeders
  class BookingSeeder < BaseSeeder
    def seed_development
      {
        requests: seeds[:homes].map { |home| create_list(:booking, 1, initial_state: :unconfirmed_request, home: home) },
        bookings: seeds[:homes].map { |home| create_list(:booking, 1, initial_state: :open_request, home: home) }
      }
    rescue ActiveRecord::RecordInvalid
      {}
    end
  end
end
