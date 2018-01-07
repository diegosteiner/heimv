require_relative './base_seeder'

module Seeders
  class ApplicationSeeder < BaseSeeder
    def seed
      [UserSeeder, HomeSeeder, CustomerSeeder].inject({}) do |seeds, seeder|
        seeds.tap { |s| s[seeder] = seeder.new(@options, s).seed }
      end
    end
  end
end
