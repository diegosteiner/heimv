# frozen_string_literal: true

class InvoiceAddress
  def initialize(booking)
    @booking = booking
  end

  delegate :tenant_organisation, to: :@booking

  def lines
    @lines ||= if tenant_organisation.blank? && booking_invoice_address_lines.blank?
                 tenant_address_lines
               else
                 [
                   [tenant_organisation, booking_invoice_address_lines[0]].uniq,
                   booking_invoice_address_lines[1..]
                 ].flatten.compact_blank
               end
  end

  def represented_by
    @represented_by ||= booking_invoice_address_lines.present? ? [@booking.tenant&.name] : tenant_address_lines
  end

  def booking_invoice_address_lines
    @booking_invoice_address_lines ||= @booking.invoice_address&.lines&.map(&:chomp)&.compact_blank || []
  end

  def tenant_address_lines
    @tenant_address_lines ||= @booking.tenant&.full_address_lines&.map(&:chomp)&.compact_blank
  end
end
