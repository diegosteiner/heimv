class InvoiceSerializer < ApplicationSerializer
  belongs_to :booking

  attributes :invoice_type, :text, :issued_at, :payable_until, :esr_number
end
