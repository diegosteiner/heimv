# frozen_string_literal: true

require 'active_support/concern'

module BookingState
  extend ActiveSupport::Concern

  delegate :current_state, :current_state, to: :state_machine
  delegate :booking_strategy, to: :organisation

  class_methods do
    def initial_state
      @initial_state || :initial
    end

    def transition_class
      BookingTransition
    end
  end

  included do
    include Statesman::Adapters::ActiveRecordQueries

    attr_accessor :transition_to, :skip_infer_transition, :initial_state

    has_many :booking_transitions, dependent: :destroy, autosave: false

    after_save :state_transition
    after_touch :state_transition

    validate do
      if transition_to.present? && !state_machine.can_transition_to?(transition_to)
        errors.add(:transition_to,
                   I18n.t(:'activerecord.errors.models.booking.attributes.state.invalid_transition',
                          transition: "#{state_was}-->#{state}"))
      end
    end
  end

  def state_machine
    @state_machine ||= booking_strategy.state_machine_class.new(self, transition_class: self.class.transition_class)
  end

  def current_state
    return @current_state if @current_state&.to_s == state_machine.current_state

    @current_state = state_machine.class.state_classes[state_machine.current_state&.to_sym]&.new(self)
  end

  def state_transition
    return unless valid?

    state_machine.transition_to(transition_to) && self.transition_to = nil if transition?
    state_machine.auto.tap { errors.clear } unless skip_infer_transition
  end

  def transition?
    transition_to.present? && current_state.to_s != transition_to.to_s
  end
end
