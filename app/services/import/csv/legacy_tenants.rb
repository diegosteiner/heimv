module Import
  module CSV
    class LegacyBookings < Base
      def self.default_options
        super.merge(col_sep: ';')
      end

      protected

      def process_row(row, result); end

      def create_tenant(row)
        #  id                   :bigint(8)        not null, primary key
        #  first_name           :string
        #  last_name            :string
        #  street_address       :string
        #  zipcode              :string
        #  city                 :string
        #  country              :string
        #  reservations_allowed :boolean
        #  phone                :text
        #  email                :string           not null
        #  search_cache         :text             not null
        #  birth_date           :date
        #  created_at           :datetime         not null
        #  updated_at           :datetime         not null
        Tenant.create(
          first_name: row[:mietervorname], last_name: row[:mietername],
          street_address: [row[:mieteradresse], row[:mieteradresszusatz]].join("\n"), zipcode: row[:mieterplz],
          city: row[:mieterort], country: extract_country(row), import_data: row.to_h,
          reservations_allowed: true
        )
      end

      def extract_country(row)
        country = ISO3166::Country.find_by(name: row[:mieterland])
        country.first
      end
    end
  end
end
