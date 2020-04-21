# == Schema Information
#
# Table name: payments
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  data       :jsonb
#  paid_at    :date
#  ref        :string
#  remarks    :text
#  write_off  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :uuid
#  invoice_id :bigint
#
# Indexes
#
#  index_payments_on_booking_id  (booking_id)
#  index_payments_on_invoice_id  (invoice_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (invoice_id => invoices.id)
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

  scope :ordered, -> { order(paid_at: :DESC) }

  attribute :confirm, default: true

  after_create :confirm!, if: :confirm?

  before_validation do
    self.booking ||= invoice&.booking
  end

  def duplicates
    Payment.where(booking: booking, paid_at: paid_at, amount: amount).where.not(id: [id])
  end

  def confirm!
    PaymentConfirmation.new(self).deliver unless write_off?
  end

  def to_liquid
    Manage::PaymentSerializer.new(self).serializable_hash.deep_stringify_keys
  end
end
