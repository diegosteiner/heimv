Dir[Rails.root.join('db/seeders/**/*.rb')].sort.each { |f| require f }

Rails.logger.debug Seeders::ApplicationSeeder.new.seed
