# frozen_string_literal: true

class InvoiceAddressService
  def initialize(booking)
    @booking = booking
  end

  delegate :tenant_organisation, to: :@booking

  def lines
    @lines ||= if tenant_organisation.blank? && booking_invoice_address_lines.blank?
                 tenant_address_lines
               else
                 represented_by = booking_invoice_address_lines.present? ? @booking.tenant&.name : tenant_address_lines
                 [
                   [tenant_organisation, booking_invoice_address_lines&.shift].uniq,
                   booking_invoice_address_lines,
                   { represented_by: }
                 ].flatten
               end
  end

  def booking_invoice_address_lines
    @booking_invoice_address_lines ||= @booking.invoice_address&.lines&.map(&:chomp)&.compact_blank
  end

  def tenant_address_lines
    @tenant_address_lines ||= @booking.tenant&.full_address_lines&.map(&:chomp)&.compact_blank
  end
end
