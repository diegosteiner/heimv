module Import
  class Result
    attr_accessor :errors, :records

    def initialize
      @records = {}
      @errors  = []
    end

    def success?
      errors.none?
    end

    def <<(record)
      return if record.blank?

      records[record.class] ||= []
      records[record.class] << record
    end
  end
end
