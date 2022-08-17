# frozen_string_literal: true

require 'active_support/concern'

module BookingStateConcern
  extend ActiveSupport::Concern
  included do
    include Statesman::Adapters::ActiveRecordQueries[transition_class: Booking::StateTransition,
                                                     initial_state: :initial,
                                                     transition_name: :state_transition]
    delegate :can_transition_to?, :in_state?, to: :booking_flow

    attr_accessor :transition_to, :skip_infer_transitions, :previous_transitions

    after_save :apply_transitions
    after_touch :apply_transitions
  end

  def apply_transitions(transitions = transition_to, metadata: nil, infer_transitions: !skip_infer_transitions)
    applied_transitions = Array.wrap(transitions).compact.each do |next_transition|
      next booking_flow.transition_to(next_transition, metadata: metadata) if can_transition_to?(next_transition)

      errors.add(:transition_to, :invalid_transition, transition: next_transition)
      return false
    end
    applied_transitions += booking_flow.infer if infer_transitions
    self.transition_to = nil
    self.previous_transitions ||= []
    self.previous_transitions += applied_transitions.flatten.compact_blank
  end

  def booking_flow_class
    @booking_flow_class ||= (booking_flow_type && BookingFlows.const_get(booking_flow_type).new) ||
                            organisation&.booking_flow_class
  end

  def booking_flow
    @booking_flow ||= booking_flow_class&.new(self)
  end

  def booking_state
    return unless booking_flow
    return @booking_state if @booking_state&.to_s == booking_flow.current_state

    @booking_state = BookingStates.all[booking_flow.current_state&.to_sym]&.new(self)
  end
end
