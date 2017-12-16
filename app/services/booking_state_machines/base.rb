module BookingStateMachines
  class Base
    include Statesman::Machine

    state :initial, initial: true

    def prefered_transition
      raise NotImplementedError
    end

    class << self
      def automatic_transition(options = {}, &block)
        # add_callback(callback_type: :guards, callback_class: Guard,
        #  from: options[:from], to: options[:to], &block)
      end
    end
  end
end
