module BookingStrategies
  class Default
    module BookingActions
      class Public < BookingStrategy::BookingActions
        register Cancel
        register ExtendDeadline
      end
    end
  end
end
