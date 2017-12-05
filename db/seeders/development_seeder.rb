require_relative './base_seeder'

module Seeders
    class DevelopmentSeeder < BaseSeeder
        attr_accessor :users

        def initialize
            self.users = {}
        end

        def seed
            seed_users
            seed_homes
            seed_customers
        end

        protected

        def seed_users
            self.users[:admin] = create(:user, :admin, email: 'admin@hv.dev')
            self.users[:user] = create(:user, email: 'user@hv.dev')
        end

        def seed_homes
            create(:home)
        end

        def seed_customers
            create_list(:customer, 10)
        end
    end
end
