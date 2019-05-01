module Import
  module CSV
    class LegacyBookings < Base
      def self.default_options
        super.merge(col_sep: ';')
      end

      protected

      def process_row(row, result)
        #   result << booking
        # rescue StandardError => e
        #   pp row
        #   raise ex
      end
    end
  end
end
