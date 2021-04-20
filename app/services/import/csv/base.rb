# frozen_string_literal: true

module Import
  module Csv
    class Base
      attr_reader :options

      def initialize(**options)
        @options = options
      end

      def new_record
        raise NotImplementedError
      end

      def read(input = ARGF, **options)
        Booking.transaction do
          options.reverse_merge!({ headers: true })
          result = CSV.parse(input, **options).map { import_row(_1, new_record) }
          raise ActiveRecord::Rollback, :dry_run if options[:dry_run].present?

          result
        end
      end

      def import_row(row, record)
        self.class.actors.each do |actor_block|
          instance_exec(record, row, &actor_block)
        end

        record.save!
        record
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
