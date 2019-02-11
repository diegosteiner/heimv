class BookingStrategy
  class BookingAction
    extend Translatable

    def initialize(booking)
      @booking = booking
    end

    def call
      return false unless allowed?

      call!
    end

    def self.action_name
      name.demodulize.underscore
    end

    def to_s
      self.class.action_name
    end

    def variant
      :primary
    end
  end
end
