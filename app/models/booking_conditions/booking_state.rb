# frozen_string_literal: true

module BookingConditions
  class BookingState < Comparable
    BookingCondition.register_subtype self

    attribute :compare_operator, default: -> { :'=' }

    compare_operator '=': ->(booking:, compare_value:) { booking.booking_flow.current_state&.to_s == compare_value },
                     '>': ->(booking:, compare_value:) { booking_state_transitions_include?(booking, compare_value) },
                     '<': ->(booking:, compare_value:) { !booking_state_transitions_include?(booking, compare_value) },
                     '!=': ->(**with) { !evaluate_operator(:'=', with:) }

    validates :compare_value, :compare_operator, presence: true

    def self.compare_values(organisation)
      organisation.booking_flow_class.state_classes.transform_values(&:translate).to_a
    end

    def evaluate!(booking)
      evaluate_operator(compare_operator, with: { booking:, compare_value: })
    end

    protected

    def booking_state_transitions_include?(booking, state)
      booking.state_transitions.pluck(:to_state).include?(state&.to_s)
    end
  end
end
