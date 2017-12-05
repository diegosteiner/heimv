class Booking < ApplicationRecord
  STATE_MACHINE = BookingStateMachine
  STATES = STATE_MACHINE.states_enum_hash.freeze
  enum state: STATES

  belongs_to :occupancy, dependent: :destroy
  belongs_to :home
  belongs_to :customer, class_name: :Customer, inverse_of: :bookings
  has_many :booking_transitions, dependent: :destroy, autosave: false
  has_many :contracts, dependent: :destroy, autosave: false

  before_validation :set_initial_state, :set_dependent_attributes

  validates :home, :customer, presence: true
  validates :state, inclusion: {
    in: ->(booking) { booking.state_machine.allowed_or_current_transitions },
    message: I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition')
  }
  validate do
    if state_changed? && !state_machine.can_transition_to?(state)
      errors.add(:state, I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition'))
    end
  end

  before_save :state_transition, if: ->(booking) { booking.state_changed? }

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank
  accepts_nested_attributes_for :customer, reject_if: :all_blank

  def state_changed?
    super && state != state_machine.current_state
  end

  def ref
    # TODO: Save this as an attribute
    RefService.new.booking(self)
  end

  def state_machine
    @state_machine ||= STATE_MACHINE.new(self, transition_class: BookingTransition)
  end

  def to_s
    RefService.new.booking(self)
  end

  private

  def state_transition
    state_machine.transition_to(state) if state_changed?
    self.state = state_machine.current_state
  end

  def set_dependent_attributes
    occupancy.home ||= home
  end

  def set_initial_state
    self.state ||= state_machine.current_state
  end
end
