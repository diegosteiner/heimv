module BookingStrategies
  class Default
    module Actions
      class Public < BookingStrategy::Actions
        register Cancel
        register ExtendDeadline
      end
    end
  end
end
