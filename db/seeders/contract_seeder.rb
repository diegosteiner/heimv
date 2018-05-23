require_relative './base_seeder'

module Seeders
  class InvoiceSeeder < BaseSeeder
    def seed_development
      {
        invoices: seeds.fetch(:bookings, []).map do |booking|
          next unless booking.state == 'confirmed'
          create(:contract, booking: booking)
        end
      }
    end
  end
end
