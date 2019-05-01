module Import
  class Result
    def records
      @records ||= {}
    end

    def invalid_records
      records.values.flatten.reject(&:valid?)
    end

    def errors
      invalid_records.map(&:errors)
    end

    def self.in_transaction(&block)
      new.tap do |result|
        ActiveRecord::Base.transaction do
          yield(result)
          raise ActiveRecord::Rollback if result.invalid_records.any?
        end
      end
    end

    def <<(record)
      return unless record.present?

      records[record.class] ||= []
      records[record.class] << record
    end
  end
end
