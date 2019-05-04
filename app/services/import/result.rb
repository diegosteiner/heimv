module Import
  class Result
    def records
      @records ||= {}
    end

    def invalid_records
      records.values.flatten.select { |record| record.respond_to?(:valid?) && !record.valid? }
    end

    def success?
      invalid_records.any?
    end

    def errors
      invalid_records.map(&:errors)
    end

    def <<(record)
      return if record.blank?

      records[record.class] ||= []
      records[record.class] << record
    end
  end
end
