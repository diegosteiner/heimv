class Organisation < ApplicationRecord

  def booking_strategy
    BookingStrategy::Default
  end
end
