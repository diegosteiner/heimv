namespace :db do
  namespace :seed do
    desc "Dump current database state to seed file"
    task dump: :environment do
      env = ENV['SEED_ENV']&.to_sym || Rails.env.to_sym
      ImportSeeder.new.dump(env)
      puts "Database dumped to #{ImportSeeder::FILES[env]}"
    end
  end
end
