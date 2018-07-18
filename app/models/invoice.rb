class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices
  has_many :invoice_parts

  enum invoice_type: %i[deposit invoice late_notice]

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank
end
