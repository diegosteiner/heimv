require 'active_support/concern'

module BookingState
  extend ActiveSupport::Concern

  included do
    attr_accessor :transition_to
    has_many :booking_transitions, dependent: :destroy, autosave: false
    after_save :state_transition

    validate do
      if state_changed? && !state_machine.can_transition_to?(transition_to)
        transition = "#{state_was}-->#{state}"
        errors.add(
          :state,
          I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition', transition: transition)
        )
      end
    end
  end

  class_methods do
    def transition_class
      BookingTransition
    end

    def state_machine_class
      StateMachines::DefaultBookingStateMachine
    end
  end

  def state_machine
    @state_machine ||= self.class.state_machine_class.new(self, transition_class: self.class.transition_class)
  end

  private

  def state_transition
    return unless state_machine.current_state != transition_to
    state_machine.transition_to(transition_to)
  end
end
