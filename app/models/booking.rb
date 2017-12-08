class Booking < ApplicationRecord
  STATE_MACHINE = BookingStateMachine
  STATES = STATE_MACHINE.states_enum_hash.freeze
  enum state: STATES

  has_one :occupancy, dependent: :destroy, as: :subject, autosave: true
  belongs_to :home
  belongs_to :customer, inverse_of: :bookings
  has_many :booking_transitions, dependent: :destroy, autosave: false
  has_many :contracts, dependent: :destroy, autosave: false

  validates :home, :customer, :occupancy, presence: true
  validates :state, inclusion: {
    in: ->(booking) { booking.state_machine.allowed_or_current_transitions },
    message: I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition')
  }
  validate do
    if state_changed? && !state_machine.can_transition_to?(state)
      errors.add(:state, I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition'))
    end
  end

  before_validation :set_state_attributes, :set_occupancy_attributes
  before_save :state_transition, if: ->(booking) { booking.state_changed? }

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank
  accepts_nested_attributes_for :customer, reject_if: :all_blank

  # delegate :begins_at, :begins_at=, :ends_at, :ends_at=, to: :occupancy

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
    ref
  end

  # def occupancy
  #   @occupancy ||= build_occupancy
  # end

  private

  def state_transition
    state_machine.transition_to(state) if state_changed?
    self.state = state_machine.current_state
  end

  def set_occupancy_attributes
    self.occupancy ||= build_occupancy
    occupancy.home ||= home
    occupancy.subject ||= self
  end

  def set_state_attributes
    self.state ||= state_machine.current_state
  end
end
