module BookingStrategy
  module Default
    class Validator < BookingStrategy::Validator
      def validate(record); end
    end
  end
end
