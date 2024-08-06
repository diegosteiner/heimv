# frozen_string_literal: true

module Import
  class Result
    extend ActiveModel::Translation
    extend ActiveModel::Naming
    attr_reader :records, :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
      @records = []
    end

    def add(record)
      records << record
      record.errors.each do |record_error|
        errors.import(record_error, attribute: "##{records.count}.#{record_error.attribute}")
      end
    end

    def ok?
      errors.none? && records.compact.all?(&:valid?)
    end
  end
end
