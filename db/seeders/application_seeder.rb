require_relative './base_seeder'

module Seeders
  class ApplicationSeeder < BaseSeeder
    def seed
      [
        UserSeeder,
        HomeSeeder,
        TarifSeeder,
        TenantSeeder,
        BookingAgentSeeder,
        BookingSeeder,
        MarkdownTemplateSeeder,
        TarifSelectorSeeder
      ].inject({}) do |seeds, seeder|
        seeds.merge(seeder.new(@options, seeds).seed)
      end
    end
  end
end
