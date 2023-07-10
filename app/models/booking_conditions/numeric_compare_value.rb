# frozen_string_literal: true

module BookingConditions
  module NumericCompareValue
    COMPARE_VALUE_REGEX = /\A(?<operator>[><=]=?)?(?<threshold>\d*(?<threshold_decimal>\.\d+)?)?\z/

    protected

    def evaluate_numeric(value)
      return if value.blank? || compare_value_match.blank? || compare_value_match[:threshold].blank?

      self.class.binary_comparison(value, compare_value_match[:threshold].to_f,
                                   operator: compare_value_match[:operator])
    end
  end
end
