require_relative "./base_seeder"

module Seeders
  class HomeSeeder < BaseSeeder
    def seed_development
      organisation = @seeds[:organisations].first
      {
        homes: [
          create(:home, {
            name: "Birchli",
            ref: "bir",
            janitor: "Peter Muster, 079 999 99 99",
            organisation: organisation,
          }),
          create(:home, {
            name: "Mühlebächli",
            ref: "muehli",
            janitor: "Peter Muster, 079 999 99 99",
            organisation: organisation,
          }),
          create(:home, {
            name: "Villa Kunterbunt",
            ref: "villa",
            janitor: "Peter Muster, 079 999 99 99",
            organisation: organisation,
          }),
        ],
      }
    end
  end
end
