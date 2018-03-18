class Invoice < ApplicationRecord
  belongs_to :booking

  enum invoice_type: %i[deposit invoice late_notice]

  validates :booking, presence: true
end
