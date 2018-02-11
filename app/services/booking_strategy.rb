module BookingStrategy
  class << self
    def infer(booking)
      BookingStrategy::Default::Instance.new(booking)
    end

    alias [] infer
  end
end
