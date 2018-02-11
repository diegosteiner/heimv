require 'active_support/concern'

module BookingState
  extend ActiveSupport::Concern

  included do
    attr_accessor :transition_to
    has_many :booking_transitions, dependent: :destroy, autosave: false
    after_save :state_transition

    validate do
      if transition_to.present? && !state_manager.can_transition_to?(transition_to)
        errors.add(:transition_to,
                   I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition',
                          transition: "#{state_was}-->#{state}"))
      end
    end
  end

  def state_manager
    @state_manager = BookingStrategy.infer(self).state_manager
  end

  private

  def state_transition
    return unless state_manager.current_state != transition_to
    state_manager.transition_to(transition_to)
  end
end
