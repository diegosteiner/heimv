# frozen_string_literal: true

module BookingConditions
  module NumericDistinction
    DISTINCTION_REGEX = /\A(?<operator>[><=]=?)?(?<threshold>\d*(?<threshold_decimal>\.\d+)?)?\z/

    protected

    def evaluate_numeric(value)
      return if value.blank? || distinction_match.blank? || distinction_match[:threshold].blank?

      self.class.binary_comparison(value, distinction_match[:threshold].to_f, operator: distinction_match[:operator])
    end
  end
end
