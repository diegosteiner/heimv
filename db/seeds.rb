Dir[Rails.root.join('db', 'seeders', '**', '*.rb')].each { |f| require f }

pp Seeders::ApplicationSeeder.new.seed
