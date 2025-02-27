# frozen_string_literal: true

module BookingConditions
  class Occupiable < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_attribute occupiable: ->(booking:) { booking.occupiable_ids },
                      home: ->(booking:) { booking.home_id }

    compare_operator '=': ->(actual_value:, compare_value:) { actual_value.include?(compare_value.presence&.to_i) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_attribute, :compare_operator, presence: true
    validate do
      errors.add(:compare_value, :invalid) unless self.class.compare_values(organisation).exists?(id: compare_value)
    end

    def evaluate!(booking)
      actual_value = evaluate_attribute(compare_attribute, with: { booking: })
      actual_value = Array.wrap(actual_value).compact_blank.map(&:to_i)
      evaluate_operator(compare_operator.presence || :'=', with: { actual_value:, compare_value: })
    end

    def self.compare_values(organisation)
      organisation.occupiables.ordered
    end
  end
end
