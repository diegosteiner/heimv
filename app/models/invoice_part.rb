class InvoicePart < ApplicationRecord
  include RankedModel

  belongs_to :invoice, inverse_of: :invoice_parts
  belongs_to :usage, inverse_of: :invoice_parts, optional: true

  attribute :apply, :boolean, default: true

  after_save do
    invoice.recalculate_amount
  end

  ranks :row_order, with_same: :invoice_id

  validates :type, presence: true
end
