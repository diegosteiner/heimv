# frozen_string_literal: true

module BookingConditions
  class OneOf < Composition
    BookingCondition.register_subtype self

    def evaluate!(booking)
      conditions.none? || conditions.any? { it.evaluate!(booking) }
    end
  end
end
