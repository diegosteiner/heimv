require 'active_support/concern'

module BookingState
  extend ActiveSupport::Concern

  included do
    attr_accessor :transition_to
    has_many :booking_transitions, dependent: :destroy, autosave: false
    after_save :state_transition

    validate do
      if transition_to.present? && !state_machine.can_transition_to?(transition_to)
        errors.add(:transition_to,
                   I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition',
                          transition: "#{state_was}-->#{state}"))
      end
    end
  end

  def booking_strategy
    @booking_strategy ||= BookingStrategy.infer(self)
  end

  def state_machine
    @state_machine ||= booking_strategy::StateMachine.new(self)
  end

  private

  def state_transition
    return unless state_machine.current_state != transition_to
    state_machine.transition_to(transition_to)
  end
end
