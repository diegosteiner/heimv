module Import
  module CSV
    class LegacyBookings < Base
      def self.default_options
        super.merge(col_sep: ';')
      end

      protected

      def process_row(row, _result)
        create_tenant(row)
      end

      def create_tenant(row)
        Tenant.create(
          first_name: row[:mietervorname], last_name: row[:mietername],
          street_address: [row[:mieteradresse], row[:mieteradresszusatz]].join("\n"), zipcode: row[:mieterplz],
          city: row[:mieterort], country: extract_country(row), email: row[:mieteremail], phone: extract_phone(row),
          reservations_allowed: true, remarks: row[:mieterbemerkungen], import_data: row.to_h
        )
      end

      def extract_phone(row)
        [row[:mieterteln], row[:mietertelp], row[:mietertelg]].select(&:present?).join("\n")
      end

      def extract_country(row)
        country = ISO3166::Country.find_by(name: row[:mieterland])
        country.first
      end
    end
  end
end
