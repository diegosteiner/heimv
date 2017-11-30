require_relative './base_seeder'

module Seeders
    class DevelopmentSeeder < BaseSeeder
        attr_accessor :users

        def initialize
            self.users = {}
        end

        def seed
            seed_users
        end

        protected

        def seed_users
            self.users[:admin] = create(:user, :admin, email: 'admin@hv.dev')
            self.users[:user] = create(:user, email: 'user@hv.dev')
        end
    end
end
