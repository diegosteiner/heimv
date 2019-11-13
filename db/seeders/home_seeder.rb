require_relative "./base_seeder"

module Seeders
  class HomeSeeder < BaseSeeder
    seed :development do |seeds|
      {
        homes: [
          create(:home, {
            name: "Birchli",
            ref: "bir",
            janitor: "Peter Muster, 079 999 99 99",
            organisation: Organisation.instance
          }),
          create(:home, {
            name: "Mühlebächli",
            ref: "muehli",
            janitor: "Peter Muster, 079 999 99 99",
            organisation: Organisation.instance
          }),
          create(:home, {
            name: "Villa Kunterbunt",
            ref: "villa",
            janitor: "Peter Muster, 079 999 99 99",
            organisation: Organisation.instance
          }),
        ],
      }
    end
  end
end
