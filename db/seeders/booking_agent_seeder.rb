require_relative './base_seeder'

module Seeders
  class BookingAgentSeeder < BaseSeeder
    seed :development do |seeds|
      {
        booking_agents: create_list(:booking_agent, 2)
      }
    end
  end
end
