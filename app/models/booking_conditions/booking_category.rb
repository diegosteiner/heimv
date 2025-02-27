# frozen_string_literal: true

module BookingConditions
  class BookingCategory < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': lambda { |actual_value:, compare_value:|
                            [actual_value&.key, actual_value&.id&.to_s].compact_blank.include?(compare_value&.to_s)
                          },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_operator, presence: true
    validate do
      next if self.class.compare_values(organisation).exists?(key: compare_value) ||
              self.class.compare_values(organisation).exists?(id: compare_value)

      errors.add(:compare_value, :invalid)
    end

    def evaluate!(booking)
      actual_value = booking.category
      evaluate_operator(compare_operator || :'=', with: { actual_value:, compare_value: })
    end

    def self.compare_values(organisation)
      organisation.booking_categories.ordered
    end
  end
end
