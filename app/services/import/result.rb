module Import
  class Result
    attr_accessor :errors, :records

    def initialize(dry_run: ENV['IMPORT_DRY_RUN'].present?)
      @records = []
      @errors  = []
      @dry_run = dry_run
    end

    def success?
      errors.none?
    end

    def dry_run?
      @dry_run.present?
    end

    def <<(record)
      return if record.blank?

      records << record
      errors << record.errors if record.errors.any?
    end

    def self.wrap(&block)
      new.tap do |result|
        ApplicationRecord.transaction do
          result.tap(&block)
          raise ActiveRecord::Rollback unless result.success? && !result.dry_run?
        end
      end
    end

    def to_s
      return "success! #{records.count} records" if success?

      "fail! #{errors.count} errors in #{records.count} records"
    end
  end
end
