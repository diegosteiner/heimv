Dir[Rails.root.join('db', 'seeders', '**', '*.rb')].each { |f| require f }

Seeders::ApplicationSeeder.new.seed
