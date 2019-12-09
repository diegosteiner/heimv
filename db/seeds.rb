Dir[Rails.root.join('db/seeders/**/*.rb')].each { |f| require f }

Rails.logger.debug Seeders::ApplicationSeeder.new.seed
