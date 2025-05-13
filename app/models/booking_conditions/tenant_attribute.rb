# frozen_string_literal: true

module BookingConditions
  class TenantAttribute < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute country_code: ->(tenant:) { tenant&.country_code&.upcase },
                      locale: ->(tenant:) { tenant&.locale&.downcase }

    compare_operator(**NUMERIC_OPERATORS)

    validates :compare_attribute, :compare_operator, presence: true

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { tenant: booking.tenant })
      return if actual_value.nil? || compare_value.nil?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: })
    end
  end
end
