class BookingMailerViewModel
  attr_accessor :booking, :to

  delegate :public_id, to: :booking

  def initialize(booking, to = nil)
    @booking = booking
    @to = to
  end
end
