# frozen_string_literal: true

module BookingConditions
  class Tarif < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': ->(actual_value:, compare_value:) { actual_value.include?(compare_value.presence&.to_i) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_operator, :compare_value, presence: true
    validate do
      errors.add(:compare_value, :invalid) unless self.class.compare_values(organisation).exists?(id: compare_value)
    end

    def evaluate!(booking)
      actual_value = booking.usages.map(&:tarif_id)
      evaluate_operator(compare_operator || :'=', with: { actual_value:, compare_value: })
    end

    def self.compare_values(organisation)
      organisation.tarifs.ordered
    end
  end
end
