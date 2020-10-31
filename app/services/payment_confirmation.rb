# frozen_string_literal: true

class PaymentConfirmation
  attr_reader :payment
  delegate :booking, to: :payment
  delegate :deliver, to: :notification

  def initialize(payment)
    @payment = payment
  end

  def notification
    context = { 'booking' => booking, 'payment' => @payment }
    @notification ||= booking.notifications.new(from_template: :payment,
                                                addressed_to: :tenant,
                                                context: context)
  end
end
