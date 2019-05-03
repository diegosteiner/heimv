require_relative './base_seeder'

module Seeders
  class UserSeeder < BaseSeeder
    seed :production do |seeds|
      {
        admin: create(:user, :admin, email: 'admin@hv.dev')
      }
    end

    seed :development do |seeds|
      {
        admin: create(:user, :admin, email: 'admin@hv.dev'),
        users: [create(:user, email: 'user@hv.dev')],
        blargh: false
      }
    end
  end
end
