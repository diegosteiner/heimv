# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id            :bigint           not null, primary key
#  amount        :decimal(, )
#  data          :jsonb
#  paid_at       :date
#  ref           :string
#  remarks       :text
#  write_off     :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  booking_id    :uuid
#  camt_instr_id :string
#  invoice_id    :bigint
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
  MailTemplate.define(:payment_confirmation_notification, context: %i[booking payment])
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
  scope :recent, -> { where(arel_table[:paid_at].gt(3.months.ago)) }

  after_create :confirm!, if: :confirm?
  after_destroy :recalculate_invoice
  after_save :recalculate_invoice

  before_validation do
    self.booking = invoice&.booking || booking
  end

  def duplicates
    Payment.where(booking:, paid_at:, amount:, camt_instr_id:).where.not(id: [id])
  end

  def confirm!
    return if write_off || !confirm?

    MailTemplate.use(:payment_confirmation_notification, booking, to: :tenant, booking:, payment: self, &:autodeliver)
  end

  def recalculate_invoice
    return if invoice.blank?

    invoice.recalculate
    invoice.save if invoice.amount_open_changed?
  end
end
