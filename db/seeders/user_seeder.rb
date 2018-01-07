require_relative './base_seeder'

module Seeders
  class UserSeeder < BaseSeeder
    def seed
      if production?
        {
          admin: create(:user, :admin, email: 'admin@hv.dev')
        }
      else
        {
          admin: create(:user, :admin, email: 'admin@hv.dev'),
          users: [create(:user, email: 'user@hv.dev')]
        }
      end
    end
  end
end
