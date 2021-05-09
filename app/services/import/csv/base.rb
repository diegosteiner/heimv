# frozen_string_literal: true

module Import
  module Csv
    class Base
      attr_reader :options

      def initialize(**options)
        @options = default_options.deep_merge(options)
      end

      def initialize_record(_row)
        raise NotImplementedError
      end

      def persist_record(record)
        record.save
      end

      def default_options
        { csv: { header_converters: :downcase, headers: true } }
      end

      def read(input = ARGF, **options)
        options.reverse_merge!(default_options)
        ActiveRecord::Base.transaction do
          result = CSV.parse(input, **options.fetch(:csv)).map { import_row(_1, **options) }
          raise ActiveRecord::Rollback, :dry_run if options[:dry_run].present?

          result
        end
      end

      def import_row(row, **options)
        initialize_record(row).tap do |record|
          self.class.actors.each do |actor_block|
            instance_exec(record, row, options, &actor_block)
          end
          persist_record(record)
        end
      end

      def self.actor(&block)
        actors << block
      end

      def self.actors
        @actors ||= []
      end
    end
  end
end

class CSV
  class Row
    def try_field(*names)
      names.each do |name|
        return self[name] if self[name].present?
      end
      nil
    end

    def try_all_fields(*names)
      names.each_with_object([]) do |name, aggregator|
        aggregator << self[name] if self[name].present?
      end
    end
  end
end
