# frozen_string_literal: true

module Import
  class Result
    extend ActiveModel::Translation
    attr_reader :records, :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
      @records = []
    end

    def add(record)
      records << record
    end

    def ok?
      errors.none? && records.compact.all?(&:valid?)
    end
  end
end
