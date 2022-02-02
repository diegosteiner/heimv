# frozen_string_literal: true

module Import
  module Csv
    class Base
      attr_reader :options, :errors

      def initialize(**options)
        @options = default_options.deep_merge(options)
      end

      def initialize_record(_row)
        raise NotImplementedError
      end

      def default_options
        { csv: { header_converters: :downcase, headers: true } }
      end

      def persist_record(record)
        record.save
      end

      def parse(input = ARGF)
        Result.new.tap do |result|
          ActiveRecord::Base.transaction do
            parse!(input, result)
            raise ActiveRecord::Rollback unless result.ok?
          end
        end
      end

      def parse!(input = ARGF, result = Result.new)
        CSV.parse(input, **options.fetch(:csv)).each_with_index do |row, index|
          result.add(import_row(row)) unless skip_row?(row, index)
        end
        result
      end

      def parse_file(file)
        parse(file.read.force_encoding('UTF-8'))
      end

      def import_row(row)
        initialize_record(row)&.tap do |record|
          self.class.actors.each { |actor_block| instance_exec(record, row, options, &actor_block) }
          persist_record(record)
        end
      end

      def skip_row?(row, index = nil)
        row.values_at.all?(&:blank?) || (options.dig(:csv, :headers).is_a?(Array) && index.zero?)
      end

      def self.actor(_name = nil, &block)
        actors << block
      end

      def self.actors
        @actors ||= []
      end

      def self.supported_headers
        []
      end
    end
  end
end
