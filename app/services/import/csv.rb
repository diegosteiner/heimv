module Import
  class CSV
    def new(files = [], result = Import::Result)
    end

    def self.csv_options
      { headers: true, converters: :all, header_converters: :symbol }
    end
  end
end
