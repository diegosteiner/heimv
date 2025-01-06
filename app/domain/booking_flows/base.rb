# frozen_string_literal: true

module BookingFlows
  class Base
    extend TemplateRenderable
    include Statesman::Machine
    CircularTransitionError = Class.new(StandardError)

    class << self
      def state_classes
        @state_classes ||= {}
      end

      def callbacks
        @callbacks ||= {
          before: [],
          after: [],
          after_transition_failure: [],
          after_guard_failure: [],
          after_commit: [],
          infer: [],
          guards: []
        }
      end

      def state(state_class, initial: false, to: [])
        state_classes[state_class.to_sym] = state_class
        super(state_class, initial:)
        successors[state_class.to_s] = [successors[state_class.to_s], to].flatten.compact.map(&:to_s)
        state_class.callbacks.each do |callback_type, state_callbacks|
          callbacks[callback_type] += state_callbacks
        end
      end
    end

    def initialize(object, options = {})
      super(object, options.reverse_merge(transition_class: Booking::StateTransition,
                                          association_name: :state_transitions))
    end

    def booking_state
      return @booking_state if @booking_state&.to_s == current_state.to_s && @booking_state.booking == booking

      @booking_state = BookingStates[current_state&.to_sym]&.new(booking)
    end

    def booking
      object
    end

    def infer(max_steps = 10)
      [].tap do |passed_transitions|
        while (to = infer_next_state) && passed_transitions.count <= max_steps
          raise CircularTransitionError if passed_transitions.include?(to)

          Statesman::Machine.retry_conflicts(3) do
            passed_transitions << to if transition_to(to, metadata: { infered: true })
          end
        end
        booking.valid?
      end
    end

    def possible_transitions
      successors_for(current_state)
    end

    def rollback_to!(state)
      state = booking.state_transitions.where(to_state: state).last unless state.is_a? Booking::StateTransition
      return if state.blank?

      # rubocop:disable Rails/SkipsModelValidations
      booking.state_transitions.where(Booking::StateTransition.arel_table[:created_at].gt(state.created_at))
             .destroy_all && booking.touch
      # rubocop:enable Rails/SkipsModelValidations
    end

    def infer_next_state
      self.class.callbacks[:infer].each do |callback|
        from = callback.from.to_s
        to = callback.to.first

        next unless from == current_state&.to_s || from.blank?
        next unless callback.callback.call(booking) && can_transition_to?(to)

        return to
      end
      nil
    end
  end
end
