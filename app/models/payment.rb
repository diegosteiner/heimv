class Payment < ApplicationRecord
  belongs_to :invoice, optional: true, touch: true
  belongs_to :booking, touch: true

  validates :amount, numericality: true
  validates :paid_at, :amount, :booking, presence: true
  validate do
    errors.add(:base, :duplicate) if duplicates.exists?
  end

  before_validation do
    self.booking ||= invoice&.booking
  end

  def duplicates
    Payment.where(booking: booking, paid_at: paid_at, amount: amount).where.not(id: [id])
  end
end
