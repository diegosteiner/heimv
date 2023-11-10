# frozen_string_literal: true

class PaymentConfirmation
  MailTemplate.define(:payment_confirmation_notification, context: %i[booking payment])

  attr_reader :payment

  delegate :booking, to: :payment
  delegate :deliver, to: :notification

  def initialize(payment)
    @payment = payment
  end

  def notification
    @notification ||= MailTemplate.use(:payment_confirmation_notification, booking, to: :tenant, payment: @payment)
  end
end
