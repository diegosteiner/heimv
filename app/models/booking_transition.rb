class BookingTransition < ApplicationRecord
  belongs_to :booking, inverse_of: :booking_transitions, touch: true

  after_destroy :update_most_recent, if: :most_recent?
  before_save :serialize_booking
  after_save :update_booking_state

  private

  def serialize_booking
    self.booking_data = booking.attributes
  end

  def update_booking_state
    # rubocop:disable Rails/SkipsModelValidations
    booking.update_columns(state: to_state)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def update_most_recent
    last_transition = booking.booking_transitions.order(:sort_key).last
    return if last_transition.blank?
    last_transition.update(most_recent: true)
  end
end
