require_relative './base_seeder'

module Seeders
  class BookingSeeder < BaseSeeder
    def seed_development
      {
        invoices: seeds[:bookings].map do |booking|
          create(:invoice, booking: booking)
        end
      }
    end
  end
end
