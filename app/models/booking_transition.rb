class BookingTransition < ApplicationRecord
  belongs_to :booking, inverse_of: :booking_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = booking.booking_transitions.order(:sort_key).last
    return if last_transition.blank?
    last_transition.update(most_recent: true)
  end
end
