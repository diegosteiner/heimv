class Organisation < ApplicationRecord
  def booking_strategy
    BookingStrategies::Default
  end
end
