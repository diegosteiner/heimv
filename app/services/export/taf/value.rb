# frozen_string_literal: true

module Export
  module Taf
    Value = Data.define(:value, :as) do
      CAST_BLOCKS = { # rubocop:disable Lint/ConstantDefinitionInBlock
        boolean: ->(value) { value ? '1' : '0' },
        decimal: ->(value) { format('%.2f', value) },
        number: ->(value) { value.to_i.to_s },
        date: ->(value) { value.strftime('%d.%m.%Y') },
        string: ->(value) { "\"#{value.gsub(/["']/, '""')}\"" },
        symbol: ->(value) { value.to_s },
        vector: ->(value) { "[#{value.to_a.map(&:to_s).join(',')}]" },
        value: ->(value) { value }
      }.freeze

      CAST_CLASSES = { # rubocop:disable Lint/ConstantDefinitionInBlock
        boolean: [::FalseClass, ::TrueClass], decimal: [::BigDecimal, ::Float],
        number: [::Numeric], date: [::Date, ::DateTime, ::ActiveSupport::TimeWithZone],
        string: [::String], symbol: [::Symbol]
      }.freeze

      def self.cast(value, as: nil)
        return nil if value.blank?
        return value if value.is_a?(Value)

        as = CAST_CLASSES.find { |_key, klasses| klasses.any? { |klass| value.is_a?(klass) } }&.first if as.nil?
        value = CAST_BLOCKS.fetch(as).call(value)

        new(value, as)
      end

      def serialize
        value.to_s
      end
    end
  end
end
