# frozen_string_literal: true

require 'active_support/concern'

module BookingStateConcern
  extend ActiveSupport::Concern
  included do
    include Statesman::Adapters::ActiveRecordQueries[transition_class: Booking::StateTransition,
                                                     initial_state: :initial,
                                                     transition_name: :state_transition]
    delegate :can_transition_to?, :in_state?, :booking_state, to: :booking_flow, allow_nil: true

    attr_accessor :transition_to, :skip_infer_transitions, :applied_transitions

    after_save :apply_transitions
    after_touch :apply_transitions
  end

  def apply_transitions(transitions = transition_to, metadata: nil, infer_transitions: !skip_infer_transitions)
    self.applied_transitions = Array.wrap(transitions).compact_blank.map do |transition|
      next transition if can_transition_to?(transition) && booking_flow.transition_to(transition, metadata:)

      errors.add(:transition_to, :invalid_transition, transition:)
      return false
    end
    self.transition_to = nil
    self.applied_transitions += booking_flow.infer if infer_transitions
    update_booking_state_cache!
    applied_transitions
  end

  def update_booking_state_cache!
    return unless booking_state_cache != booking_state&.to_s

    update_columns(booking_state_cache: booking_state.to_s) # rubocop:disable Rails/SkipsModelValidations
  end

  def booking_flow
    return @booking_flow if @booking_flow.present?

    booking_flow_class = (booking_flow_type && BookingFlows.const_get(booking_flow_type).new) ||
                         organisation&.booking_flow_class
    @booking_flow = booking_flow_class&.new(self)
  end
end
