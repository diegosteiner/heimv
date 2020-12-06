# frozen_string_literal: true

module InvoiceParts
  class Factory
    include ActiveSupport::NumberHelper

    def suggest(invoice, invoice_parts = invoice.invoice_parts)
      usage_ids = invoice_parts.map(&:usage_id)
      [
        from_usages(invoice, invoice.booking.usages.includes(:tarif).where.not(id: usage_ids)),
        from_deposit(invoice),
        from_open_invoices(invoice)
      ].flatten
    end

    def breakdown(usage)
      I18n.t('invoice_parts.breakdown',
             used_units: number_to_rounded(usage.used_units || 0, precision: 2, strip_insignificant_zeros: true),
             unit: usage.tarif.unit,
             price_per_unit: number_to_currency(usage.tarif.price_per_unit || 0, currency: usage.organisation.currency))
    end

    def from_usages(invoice, usages)
      usages.map do |usage|
        InvoiceParts::Add.new(
          apply: apply?(invoice, usage),
          usage: usage,
          label: usage.tarif.label,
          breakdown: breakdown(usage),
          position: usage.tarif.position,
          amount: usage.price
        )
      end
    end

    def from_deposit(invoice, deposits = Invoices::Deposit.of(invoice.booking).kept)
      InvoiceParts::Add.new(
        apply: invoice.new_record? && invoice.is_a?(Invoices::Invoice),
        label: Invoices::Deposit.model_name.human,
        amount: - deposits.sum(&:amount_paid)
      )
    end

    def from_open_invoices(invoice, invoices = invoice.organisation.invoices.kept.unpaid)
      invoices.map do |unpaid_invoice|
        payable_until = unpaid_invoice.payable_until && I18n.l(unpaid_invoice.payable_until.to_date)
        InvoiceParts::Add.new(
          apply: invoice.new_record? && invoice.is_a?(Invoices::LateNotice),
          label: I18n.t('invoice_parts.unpaid_invoice', ref: unpaid_invoice.ref, payable_until: payable_until),
          amount: unpaid_invoice.amount_open
        )
      end
    end

    protected

    def apply?(invoice, usage)
      tarif_invoice_type = usage.tarif.invoice_type
      invoice.new_record? && tarif_invoice_type.present? && invoice.type.to_s == tarif_invoice_type
    end
  end
end
