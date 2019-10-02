require_relative './base_seeder'

module Seeders
  class UserSeeder < BaseSeeder
    seed :production do |seeds|
      {
        admin: create(:user, :admin, email: 'admin@heim.localhost')
      }
    end

    seed :development do |seeds|
      {
        admin: create(:user, :admin, email: 'admin@heimv.localhost'),
        users: [create(:user, email: 'user@heimv.localhost')],
        blargh: false
      }
    end
  end
end
