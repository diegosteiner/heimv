class InvoicePart < ApplicationRecord
  belongs_to :invoice, inverse_of: :invoice_parts
  belongs_to :usage, inverse_of: :invoice_parts, optional: true
end
