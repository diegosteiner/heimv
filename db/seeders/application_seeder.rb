require_relative './base_seeder'

module Seeders
  class ApplicationSeeder
    def seed(env = Rails.env)
      [
        OrganisationSeeder,
        UserSeeder,
        HomeSeeder,
        TarifSeeder,
        TenantSeeder,
        BookingAgentSeeder,
        BookingSeeder,
        MarkdownTemplateSeeder,
        TarifSelectorSeeder
      ].inject({}) do |seeded, seeder|
        seeded.merge(seeder.new.seed(seeded, env))
      end
    end
  end
end
