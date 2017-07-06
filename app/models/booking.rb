class Booking < ApplicationRecord
  STATE_MACHINE = BookingStateMachine
  STATES = STATE_MACHINE.states_enum_hash.freeze
  enum state: STATES

  belongs_to :occupancy
  belongs_to :home
  belongs_to :customer, class_name: :Person, inverse_of: :bookings
  has_many :booking_transitions, dependent: :destroy, autosave: false

  before_validation :set_initial_state

  validates :home, :customer, presence: true
  validates :state, inclusion: { in: ->(booking) { booking.state_machine.allowed_or_current_transitions } }
  validate do
    if state_changed? && !state_machine.can_transition_to?(state)
      errors.add(:state, I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition'))
    end
  end

  before_save :state_transition, if: ->(booking) { booking.state_changed? }

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank
  accepts_nested_attributes_for :customer, reject_if: :all_blank

  def state_machine
    @state_machine ||= STATE_MACHINE.new(self, transition_class: BookingTransition)
  end

  private

  def state_transition
    return true unless state_changed?
    transition_success = state_machine.transition_to(state)
    self.state = state_machine.current_state
    transition_success
  end

  def set_initial_state
    self.state ||= state_machine.current_state
    clear_attribute_changes([:state])
  end
end
