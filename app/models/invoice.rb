class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices
  has_many :invoice_parts, -> { rank(:row_order) }, inverse_of: :invoice

  enum invoice_type: %i[deposit invoice late_notice]

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true

  def recalculate_amount
    update(amount: invoice_parts.reduce(0) { |result, invoice_part| invoice_part.inject_self(result) })
  end

  def amount_payed
    # payments.sum(&:amount)
    0
  end
end
