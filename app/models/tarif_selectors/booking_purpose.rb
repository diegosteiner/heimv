module TarifSelectors
  class BookingPurpose < TarifSelector
    DISTINCTION_REGEX = /\A(camp|event)\z/

    def apply?(usage, distinction)
      distinction_match = DISTINCTION_REGEX.match(distinction)
      distinction_match[1] == usage.booking.purpose
    end
  end
end
