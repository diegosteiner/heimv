class BookingStrategy
  class Action
    class NotAllowed < StandardError; end
    include Translatable

    def initialize(booking)
      @booking = booking
    end

    def call
      raise NotAllowed unless allowed?

      call!
    end

    def self.call(booking)
      new(booking).call
    end

    def self.action_name
      name.demodulize.underscore
    end

    def to_s
      self.class.action_name
    end

    def button_options
      {
        variant: 'secondary'
      }
    end
  end
end
