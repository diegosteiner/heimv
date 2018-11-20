class Payment < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :booking, touch: true

  validates :amount, numericality: true
  validates :paid_at, :amount, :booking, presence: true
  validate do
    errors.add(:base, :duplicate) if duplicates.exists?
  end

  before_validation do
    self.booking ||= invoice&.booking
  end

  after_save do
    invoice&.set_paid
  end

  def duplicates
    Payment.where(booking: booking, paid_at: paid_at, amount: amount).where.not(id: [id])
  end
end
