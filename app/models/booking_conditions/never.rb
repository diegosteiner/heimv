# frozen_string_literal: true

module BookingConditions
  class Never < BookingCondition
    BookingCondition.register_subtype self

    def evaluate!(_booking)
      false
    end
  end
end
