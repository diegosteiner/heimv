# frozen_string_literal: true

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
  belongs_to :invoice, optional: true
  belongs_to :booking, touch: true
  has_one :organisation, through: :booking

  attribute :applies, :boolean, default: true
  attribute :confirm, :boolean, default: true

  validates :amount, numericality: true
  validates :paid_at, :amount, presence: true
  validate do
    errors.add(:base, :duplicate) if duplicates.exists?
  end

  scope :ordered, -> { order(paid_at: :DESC) }
  scope :last_year, -> { where(arel_table[:paid_at].gt(1.year.ago)) }

  after_create :confirm!, if: :confirm?
  after_destroy :recalculate_invoice
  after_save :recalculate_invoice

  before_validation do
    self.booking = invoice&.booking || booking
  end

  def duplicates
    Payment.where(booking: booking, paid_at: paid_at, amount: amount).where.not(id: [id])
  end

  def confirm!
    PaymentConfirmation.new(self).deliver unless write_off
  end

  def to_liquid
    Manage::PaymentSerializer.render_as_hash(self).deep_stringify_keys
  end

  def recalculate_invoice
    invoice&.recalculate!
  end
end
