# frozen_string_literal: true

require 'active_support/concern'

module BookingStateConcern
  extend ActiveSupport::Concern
  included do
    include Statesman::Adapters::ActiveRecordQueries[transition_class: Booking::StateTransition,
                                                     initial_state: :initial, 
                                                     transition_name: :state_transition]
    delegate :can_transition_to?, :in_state?, to: :booking_flow

    attr_accessor :skip_infer_transitions

    after_save :infer_transitions
    after_touch :infer_transitions
  end

  def transition_to(transitions = [], metadata: nil)
    Array.wrap(transitions).compact.each do |next_transition|
      next booking_flow.transition_to(next_transition, metadata: metadata) if can_transition_to?(next_transition)

      errors.add(:transition_to, :invalid_transition, transition: next_transition)
      return false
    end + (infer_transitions || [])
  end

  def infer_transitions!
    booking_flow.infer
  end

  def infer_transitions
    infer_transitions! unless skip_infer_transitions
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
