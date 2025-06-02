# frozen_string_literal: true

module BookingConditions
  class Comparable < BookingCondition
    attribute :compare_attribute
    attribute :compare_operator
    attribute :compare_value
    attribute :group

    EQUALITY_OPERATORS = {
      '=': ->(actual_value:, compare_value:) { actual_value == compare_value },
      '!=': ->(actual_value:, compare_value:) { actual_value != compare_value }
    }.freeze

    NUMERIC_OPERATORS = {
      '>': ->(actual_value:, compare_value:) { actual_value > compare_value },
      '>=': ->(actual_value:, compare_value:) { actual_value >= compare_value },
      '<': ->(actual_value:, compare_value:) { actual_value < compare_value },
      '<=': ->(actual_value:, compare_value:) { actual_value <= compare_value }
    }.reverse_merge(EQUALITY_OPERATORS).freeze

    delegate :compare_operators_for_select, to: :class

    validates :compare_value, format: { with: ->(condition) { condition.class.compare_value_regex } }, allow_blank: true
    validate do
      errors.add(:compare_operator, :inclusion) if compare_operator.present? &&
                                                   !self.class.compare_operators&.key?(compare_operator.to_s.to_sym)
      errors.add(:compare_attribute, :inclusion) if compare_attribute.present? &&
                                                    !compare_attributes&.key?(compare_attribute.to_s.to_sym)
    end

    def self.compare_value_regex
      //
    end

    def evaluate_operator(operator, with: {})
      instance_exec(**with, &self.class.compare_operators.fetch(operator&.to_sym))
    end

    def evaluate_attribute(attribute, with: {})
      instance_exec(**with, &compare_attributes.fetch(attribute&.to_sym))
    end

    def to_s
      "#{model_name.human}: #{compare_attribute} #{compare_operator} #{compare_value}"
    end

    def qualifiable
      parent
    end

    def compare_attributes
      self.class.compare_attributes(organisation)
    end

    class << self
      def compare_operators
        @compare_operators ||= {}
      end

      def compare_operator(**args)
        compare_operators.merge!(args.symbolize_keys)
      end

      def compare_attributes(_organisation)
        @compare_attributes ||= {}
      end

      def compare_attribute(**args)
        compare_attributes(nil).merge!(args.symbolize_keys)
      end

      def compare_values(_organisation)
        nil
      end

      def compare_attributes_for_select(organisation)
        compare_attributes(organisation)&.keys&.map do |attribute|
          [translate(attribute, scope: :attributes, default: attribute), attribute.to_sym]
        end
      end

      def compare_operators_for_select
        compare_operators&.keys&.map { |operator| [operator.to_s, operator.to_sym] }
      end

      def compare_values_for_select(organisation)
        compare_values(organisation)&.map do |value|
          next if value.blank?

          next [value.to_s, value.id] if value.is_a?(ApplicationRecord)
          next [value.last, value.first] if value.is_a?(Array)

          [value.to_s, value.to_sym || value.to_s]
        end
      end

      def options_for_select(organisation)
        super.merge({
                      compare_attributes: compare_attributes_for_select(organisation),
                      compare_operators: compare_operators_for_select,
                      compare_value_regex: compare_value_regex.present?,
                      compare_values: compare_values_for_select(organisation)
                    })
      end
    end
  end
end
