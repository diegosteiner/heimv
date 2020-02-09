module BookingStrategies
  class Default
    module States
      class Initial < BookingStrategy::State
        def self.to_sym
          :initial
        end
      end
    end
  end
end
