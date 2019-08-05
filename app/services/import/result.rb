module Import
  class Result
    attr_accessor :errors, :records

    def initialize
      @records = []
      @errors  = []
    end

    def success?
      errors.none?
    end

    def <<(record)
      return if record.blank?

      records << record
      errors << record.errors if record.errors.any?
    end
  end
end
