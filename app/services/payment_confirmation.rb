class PaymentConfirmation
  attr_reader :payment
  delegate :booking, to: :payment

  def initialize(payment)
    @payment = payment
  end

  def deliver
    message = booking.messages.new_from_template(:payment_message, addressed_to: :tenant)

    return false if message.blank?

    message.markdown = message.markdown_template.interpolate('booking' => booking, 'payment' => @payment)
    message.deliver
  end
end
