class BookingMailerViewModel
  attr_accessor :booking, :to

  def initialize(booking, to = nil)
    @booking = booking
    @to = to
  end
end
