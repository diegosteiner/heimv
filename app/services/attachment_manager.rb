# frozen_string_literal: true

class AttachmentManager
  ATTACHABLE_BOOKING_DOCUMENTS = {
    unsent_deposits: ->(booking) { booking.invoices.deposit.unsent },
    unsent_invoices: ->(booking) { booking.invoices.invoice.unsent },
    unsent_late_notices: ->(booking) { booking.invoices.late_notice.unsent },
    unsent_offers: ->(booking) { booking.invoices.offers.unsent },
    contract: ->(booking) { booking.contract }
  }.freeze

  def initialize(booking, target:)
    @booking = booking
    @target = target
  end

  def attach_all(*attachables)
    attachables.flatten.map { attach_one(_1) }
  end

  def attach_one(attachable)
    return if attachable.blank?
    return attach_one attachable.to_attachable if attachable.respond_to?(:to_attachable)
    return attach_booking_document attachable if ATTACHABLE_BOOKING_DOCUMENTS.key?(attachable)

    @target.attach attachable
  end

  def attach_booking_document(key)
    attach_all ATTACHABLE_BOOKING_DOCUMENTS[key].call(@booking) || [] if @booking.present?
  end
end
