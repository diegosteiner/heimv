module BookingStrategy
  module Default
    class Validator < BookingStrategy::Base::Validator
      def validate(record); end
    end
  end
end
