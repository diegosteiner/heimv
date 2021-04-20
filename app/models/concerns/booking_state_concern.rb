# frozen_string_literal: true

require 'active_support/concern'

module BookingStateConcern
  extend ActiveSupport::Concern

  included do
    include Statesman::Adapters::ActiveRecordQueries[transition_class: BookingTransition, initial_state: :initial]

    attr_accessor :transition_to, :skip_infer_transition

    after_save :state_transition
    after_touch :state_transition

    validate do
      if transition_to.present? && !booking_flow.can_transition_to?(transition_to)
        transition = "#{booking_state_cache_was} --> #{booking_state_cache}"
        errors.add(:transition_to, :invalid_transition, transition: transition)
      end
    end
  end

  def state_transition
    return unless valid?

    booking_flow.transition_to(transition_to) && self.transition_to = nil if transition?
    booking_flow.auto.tap { errors.clear } unless skip_infer_transition
  end

  def booking_flow_class
    @booking_flow_class ||= booking_flow_type && BookingFlows.const_get(booking_flow_type).new ||
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

  def transition?
    transition_to.present? && booking_state.to_s != transition_to.to_s
  end
end
