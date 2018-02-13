class BookingViewModel
  attr_accessor :booking

  def initialize(booking, to = nil)
    @booking = booking
  end
end
