# frozen_string_literal: true

class AttachmentManager
  ATTACHABLE_BOOKING_DOCUMENTS = {
    unsent_deposits: ->(booking) { booking.invoices.deposit.unsent },
    unsent_invoices: ->(booking) { booking.invoices.invoice.unsent },
    unsent_late_notices: ->(booking) { booking.invoices.late_notice.unsent },
    unsent_offers: ->(booking) { booking.invoices.offers.unsent },
    contract: ->(booking) { booking.contract }
  }.freeze

  def initialize(notification, target:)
    @notification = notification
    @target = target
  end

  def attach_all(*attachables)
    attachables.flatten.map { attach_one(it) }
  end

  def attach_one(attachable)
    return if attachable.blank?
    return attach_designated_document attachable if attachable.is_a?(DesignatedDocument)
    return attach_one attachable.to_attachable if attachable.respond_to?(:to_attachable)
    return attach_booking_document attachable if ATTACHABLE_BOOKING_DOCUMENTS.key?(attachable)

    @target.attach attachable
  end

  def attach_booking_document(key)
    attach_all ATTACHABLE_BOOKING_DOCUMENTS[key].call(@notification.booking) || [] if @notification.booking.present?
  end

  def attach_designated_document(document)
    @notification.attached_designated_documents << document if document.is_a?(DesignatedDocument)
  end
end
