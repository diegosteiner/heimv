module BookingStrategy
  module Default
    class Instance < Base::Instance
      def strategy
        BookingStrategy::Default
      end
    end
  end
end
