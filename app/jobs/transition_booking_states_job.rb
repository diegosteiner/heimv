class TransitionBookingStatesJob < ApplicationJob
  queue_as :default

  def perform(bookings = Booking.inconcluded)
    bookings.find_each do |booking|
      transitions = booking.state_transition
      if Rails.env.development?
        puts "Transitions of #{booking.ref}: #{transitions.join(' => ')}"
      else
        Rails.logger.info "Transitions of #{booking.ref}: #{transitions.join(' => ')}"
      end
    end
  end
end
