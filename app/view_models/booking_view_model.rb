class BookingViewModel
  attr_accessor :booking

  def initialize(booking, _to = nil)
    @booking = booking
  end
end
