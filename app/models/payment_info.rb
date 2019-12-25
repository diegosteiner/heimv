class PaymentInfo
  extend ActiveModel::Translation
  extend ActiveModel::Naming

  attr_reader :invoice
  delegate :amount, :ref, :invoice_ref_strategy, :organisation, :booking, to: :invoice

  def initialize(invoice)
    @invoice = invoice
  end

  def invoice_address
    invoice.booking.invoice_address.presence || invoice.booking.tenant.address_lines.join("\n")
  end

  def formatted_ref
    invoice_ref_strategy.format_ref(ref)
  end

  def self.human_model_name(*args)
    model_name.human(*args)
  end
end

PaymentInfos
