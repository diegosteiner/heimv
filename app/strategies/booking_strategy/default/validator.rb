module BookingStrategy
  class Default
    class Validator < BookingStrategy::Base::Validator
      def validate(record); end
    end
  end
end
