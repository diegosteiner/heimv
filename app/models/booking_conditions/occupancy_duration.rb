# frozen_string_literal: true

module BookingConditions
  class OccupancyDuration < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    validates :compare_value, presence: true

    compare_operator(**NUMERIC_OPERATORS)

    def self.compare_value_regex
      /\A(?<threshold>\d+)\s*(?<threshold_unit>[smhd])\z/
    end

    def evaluate!(booking)
      compare_value_match = self.class.compare_value_regex.match(compare_value)
      return false unless compare_value_match

      actual_value = booking.duration
      return nil if actual_value.nil?

      compare_value = threshold_unit(compare_value_match[:threshold], compare_value_match[:threshold_unit])
      evaluate_operator(compare_operator.presence || :'=', with: { actual_value:, compare_value: })
    end

    protected

    def threshold_unit(value, unit)
      value = value.to_i
      return value.days if unit == 'd'
      return value.hours if unit == 'h'
      return value.minutes if unit == 'm'

      value.second
    end
  end
end
