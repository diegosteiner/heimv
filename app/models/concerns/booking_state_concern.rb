# frozen_string_literal: true

require 'active_support/concern'

module BookingStateConcern
  extend ActiveSupport::Concern
  included do
    include Statesman::Adapters::ActiveRecordQueries[transition_class: BookingTransition, initial_state: :initial]
    delegate :can_transition_to?, to: :booking_flow
  end

  def transition_to(transitions = [], metadata: nil, auto: true)
    Array.wrap(transitions).compact.each do |next_transition|
      next booking_flow.transition_to(next_transition, metadata: metadata) if can_transition_to?(next_transition)

      errors.add(:transition_to, :invalid_transition, transition: next_transition)
      return false
    end + (auto ? booking_flow.auto : [])
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
