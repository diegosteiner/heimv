# frozen_string_literal: true

module BookingConditions
  class AllOf < Composition
    BookingCondition.register_subtype self

    def evaluate!(booking)
      conditions.all? { it.evaluate!(booking) }
    end
  end
end
