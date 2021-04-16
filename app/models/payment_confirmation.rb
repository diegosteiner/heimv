# frozen_string_literal: true

class PaymentConfirmation
  RichTextTemplate.require_template(:payment_confirmation_notification, %i[booking payment], self)

  attr_reader :payment

  delegate :booking, to: :payment
  delegate :deliver, to: :notification

  def initialize(payment)
    @payment = payment
  end

  def notification
    context = { 'booking' => booking, 'payment' => @payment }
    @notification ||= booking.notifications.new(from_template: :payment_confirmation_notification,
                                                addressed_to: :tenant,
                                                context: context)
  end
end
