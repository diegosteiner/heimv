# frozen_string_literal: true

class PaymentConfirmation
  RichTextTemplate.define(:payment_confirmation_notification, template_context: %i[booking payment],
                                                              required_by: self)

  attr_reader :payment

  delegate :booking, to: :payment
  delegate :deliver, to: :notification

  def initialize(payment)
    @payment = payment
  end

  def notification
    context = { 'booking' => booking, 'payment' => @payment }
    @notification ||= booking.notifications.new(template: :payment_confirmation_notification,
                                                to: booking.tenant, template_context: context)
  end
end
