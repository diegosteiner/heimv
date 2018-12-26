module BookingStrategy
  module Default
    class StateContext < BookingStrategy::Base::StateContext

      actions_for :unconfirmed_request do |booking|
        [
          ButtonTo.new(:confirm_email, [ manage_booking_path(booking, booking: { transition_to: :open_request }), method: :PATCH ])
        ]
      end
    end
  end
end

