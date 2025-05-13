# frozen_string_literal: true

module BookingConditions
  class BookingAttribute < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute nights: ->(booking:) { booking.nights },
                      days: ->(booking:) { booking.nights + 1 },
                      tenant_organisation: ->(booking:) { booking.tenant_organisation },
                      approximate_headcount: ->(booking:) { booking.approximate_headcount },
                      overnight_stays: ->(booking:) { booking.approximate_headcount * booking.nights },
                      booking_editable: ->(booking:) { booking.editable? }

    compare_operator(**NUMERIC_OPERATORS)

    validates :compare_attribute, :compare_operator, presence: true

    def comparable_compare_value
      case compare_attribute&.to_sym
      when :nights, :days, :approximate_headcount, :overnight_stays
        ActiveModel::Type::Integer.new.cast(compare_value)
      when :booking_editable
        ActiveModel::Type::Boolean.new.cast(compare_value)
      else
        compare_value.presence
      end
    end

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { booking: })
      return if actual_value.nil? || comparable_compare_value.nil?

      evaluate_operator(compare_operator, with: { actual_value:, compare_value: comparable_compare_value })
    end
  end
end
