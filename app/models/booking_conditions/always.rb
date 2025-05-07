# frozen_string_literal: true

module BookingConditions
  class Always < BookingCondition
    BookingCondition.register_subtype self

    def evaluate!(_booking)
      true
    end
  end
end
