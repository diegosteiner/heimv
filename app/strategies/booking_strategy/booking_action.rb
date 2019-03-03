class BookingStrategy
  class Action
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

    def button_options
      {
        class: %i[btn btn-primary]
      }
    end
  end
end
