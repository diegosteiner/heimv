require 'factory_bot_rails'
require 'faker'

module Seeders
    class BaseSeeder
        include FactoryBot::Syntax::Methods

        def seed
        end
    end
end
