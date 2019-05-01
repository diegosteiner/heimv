module Import
  module CSV
    class Base
      def call(io, options = self.class.default_options)
        Import::Result.in_transaction do |result|
          ::CSV.foreach(io, options) do |row|
            result << process_row(row, result)
            # return result
          end
        end
      end

      def self.default_options
        { headers: true, converters: :all, header_converters: :symbol }
      end

      protected

      def process_row(row, result)
        row
      end
    end
  end
end
