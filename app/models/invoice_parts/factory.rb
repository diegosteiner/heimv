module InvoiceParts
  class Factory
    include ActiveSupport::NumberHelper

    def suggest(invoice, invoice_parts = invoice.invoice_parts)
      usage_ids = invoice_parts.map(&:usage_id)
      invoice.booking.usages.includes(:tarif).where.not(id: usage_ids).map do |usage|
        from_usage(invoice, usage)
      end + [from_deposit(invoice)]
    end

    def label_2(usage)
      I18n.t('invoice_parts.label_2',
             used_units: number_to_rounded(usage.used_units || 0, precision: 2, strip_insignificant_zeros: true),
             unit: usage.tarif.unit,
             price_per_unit: number_to_currency(usage.tarif.price_per_unit || 0, currency: usage.organisation.currency))
    end

    def from_usage(invoice, usage)
      InvoiceParts::Add.new(
        apply: apply?(invoice, usage),
        usage: usage,
        label: usage.tarif.label,
        label_2: label_2(usage),
        position: usage.tarif.position,
        amount: usage.price
      )
    end

    def from_deposit(invoice, deposits = Invoices::Deposit.of(invoice.booking).relevant)
      InvoiceParts::Add.new(
        apply: invoice.new_record? && invoice.is_a?(Invoices::Invoice),
        label: Invoices::Deposit.model_name.human,
        amount: - deposits.sum(&:amount_paid)
      )
    end

    protected

    def apply?(invoice, usage)
      tarif_invoice_type = usage.tarif.invoice_type
      invoice.new_record? && tarif_invoice_type.present? && invoice.type.to_s == tarif_invoice_type
    end
  end
end
