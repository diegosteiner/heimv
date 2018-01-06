require_relative './base_seeder'

module Seeders
  class BookingSeeder < BaseSeeder
    def seed
      return {} if production?
      {
        requests: create_list(:bookings, 10, initial_state: :request)
      }
    end
  end
end
