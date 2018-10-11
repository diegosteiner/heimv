class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :booking, touch: true

  validates :amount, numericality: true
  validates :paid_at, :amount, :booking, presence: true

  after_save do
    invoice.set_paid
  end

end
