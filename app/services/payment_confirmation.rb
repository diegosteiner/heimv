# frozen_string_literal: true

class PaymentConfirmation
  attr_reader :payment
  delegate :booking, to: :payment

  def initialize(payment)
    @payment = payment
  end

  def deliver
    notification = booking.notifications.new(from_template: :payment, addressed_to: :tenant)

    return false unless notification.valid?

    notification.markdown = notification.markdown_template&.interpolate('booking' => booking, 'payment' => @payment)
    notification.deliver!
  end
end
