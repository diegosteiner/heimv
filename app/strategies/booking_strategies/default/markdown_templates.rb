module BookingStrategies
  class Default < BookingStrategy
    MARKDOWN_TEMPLATES = %i[
      contract_text
      deposit_invoice_text
      invoice_invoice_text
      late_notice_invoice_text
      upcoming_message
      definitive_request_message
      overdue_request_message
      provisional_request_message
      confirmed_message
      open_request_message
      unconfirmed_request_message
      manage_new_booking_mail
      payment_overdue_message
      contract_signed_message
      deposit_paid_message
      invoice_paid_message
    ].freeze
  end
end
