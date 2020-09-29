# frozen_string_literal: true

class PaymentConfirmation
  attr_reader :payment
  delegate :booking, to: :payment

  def initialize(payment)
    @payment = payment
  end

  def notification
    context = { 'booking' => booking, 'payment' => @payment }
    @notification ||= booking.notifications.new(from_template: :payment_message,
                                                addressed_to: :tenant,
                                                context: context)
  end

  def deliver
    notification.deliver!
  end
end
