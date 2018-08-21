module BookingStrategy
  class << self
    def infer(_booking)
      BookingStrategy::Default
    end

    alias [] infer
  end
end
