require 'active_support/concern'

module BookingState
  extend ActiveSupport::Concern

  delegate :current_state, :state_object, to: :state_machine

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

    attr_accessor :transition_to, :skip_automatic_transition, :initial_state
    has_many :booking_transitions, dependent: :destroy, autosave: false

    scope :inconcluded, -> { where.not(state: %i[cancelled completed]) }

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
    @state_machine ||= organisation.booking_strategy.state_machine.new(self,
                                                                       transition_class: self.class.transition_class)
  end

  def state_machine_automator
    @state_machine_automator ||= organisation.booking_strategy.state_machine_automator.new(state_machine)
  end

  def state_transition
    if state_machine.current_state.to_s != transition_to.to_s
      state_machine.transition_to(transition_to) && self.transition_to = nil
    end
    return if skip_automatic_transition

    state_machine_automator.run
    errors.clear
  end
end
