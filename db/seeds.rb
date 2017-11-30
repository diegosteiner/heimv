Dir[Rails.root.join('db', 'seeders', '**', '*.rb')].each { |f| require f }

if Rails.env.production?
elsif Rails.env.development?
    Seeders::DevelopmentSeeder.new.seed
end
