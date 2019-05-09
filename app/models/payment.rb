# == Schema Information
#
# Table name: payments
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  paid_at    :date
#  ref        :string
#  invoice_id :bigint
#  booking_id :uuid
#  data       :text
#  remarks    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Payment < ApplicationRecord
  belongs_to :invoice, optional: true, touch: true
  belongs_to :booking, touch: true

  attribute :applies, :boolean, default: true

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
