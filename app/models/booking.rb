class Booking < ApplicationRecord
  class << self
    def transition_class
      BookingTransition
    end

    def state_machine_class
      BookingStateMachine
    end
  end

  has_one :occupancy, dependent: :destroy, as: :subject, autosave: true
  belongs_to :home
  belongs_to :customer, inverse_of: :bookings
  has_many :booking_transitions, dependent: :destroy, autosave: false
  has_many :contracts, dependent: :destroy, autosave: false

  validates :home, :customer, :occupancy, presence: true
  validate do
    if state_changed? && !state_machine.can_transition_to?(state)
      transition = "#{state_was}-->#{state}"
      errors.add(
        :state,
        I18n.t('activerecord.errors.models.booking.attributes.state.invalid_transition', transition: transition)
      )
    end
  end

  before_validation :set_state_attributes, :set_occupancy_attributes
  after_save :state_transition

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank
  accepts_nested_attributes_for :customer, reject_if: :all_blank

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def state_changed?
    super && state.present? && state != state_machine.current_state
  end

  def ref
    # TODO: Save this as an attribute
    @ref ||= RefService.new.booking(self)
  end

  def to_s
    ref
  end

  def state_machine
    @state_machine ||= self.class.state_machine_class.new(self, transition_class: self.class.transition_class)
  end

  private

  def state_transition
    return unless state_machine.current_state != state
    state_machine.transition_to(state)
    # rubocop:disable Rails/SkipsModelValidations
    update_columns(state: state_machine.current_state)
    # rubocop:enable Rails/SkipsModelValidations
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
