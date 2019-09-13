require_relative './base_seeder'

module Seeders
  class UserSeeder < BaseSeeder
    seed :production do |seeds|
      {
        admin: create(:user, :admin, email: 'admin@heimverwaltung.localhost')
      }
    end

    seed :development do |seeds|
      {
        admin: create(:user, :admin, email: 'admin@heimverwaltung.localhost'),
        users: [create(:user, email: 'user@heimverwaltung.localhost')],
        blargh: false
      }
    end
  end
end
