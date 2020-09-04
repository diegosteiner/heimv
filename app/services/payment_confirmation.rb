# frozen_string_literal: true

class PaymentConfirmation
  attr_reader :payment
  delegate :booking, to: :payment

  def initialize(payment)
    @payment = payment
  end

  def deliver
    message = booking.messages.new(from_template: :payment_message, addressed_to: :tenant)

    return false unless message.valid?

    message.markdown = message.markdown_template&.interpolate('booking' => booking, 'payment' => @payment)
    message.deliver!
  end
end
