module BookingStrategy
  class Base
    class BookingChecklist
      ChecklistItem = Struct.new(:key, :href, :checked)

      class << self
        attr_reader :state_procs
        def state(state_name, &block)
          @state_procs = (@state_procs || {}).merge(state_name.to_sym => block)
        end
      end

      def initialize(booking)
        @booking = booking
      end

      def to_a
        self.class.state_procs[@booking.current_state.to_sym]&.call(@booking) || []
      end
    end
  end
end
