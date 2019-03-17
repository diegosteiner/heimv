module BookingStrategies
  class Default
    module Actions
      class Public < BookingStrategy::Actions
        register CommitRequest
        register ExtendDeadline

        register Cancel
      end
    end
  end
end
