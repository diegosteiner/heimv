module Import
  module CSV
    class LegacyBookings < Base
      protected

      def process_row(row, result)
        result << booking
      rescue StandardError => ex
        pp row
        raise ex
      end

      def self.default_options
        super.merge(col_sep: ";")
      end
    end
  end
end
