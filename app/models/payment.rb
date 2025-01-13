# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#  amount                    :decimal(, )
#  data                      :jsonb
#  paid_at                   :date
#  ref                       :string
#  remarks                   :text
#  write_off                 :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  camt_instr_id             :string
#  invoice_id                :bigint
#

class Payment < ApplicationRecord
  MailTemplate.define(:payment_confirmation_notification, context: %i[booking payment])
  belongs_to :invoice, optional: true
  belongs_to :booking, touch: true

  has_one :organisation, through: :booking

  has_many :journal_entries, inverse_of: :payment, dependent: :destroy

  attribute :applies, :boolean, default: true
  attribute :confirm, :boolean, default: true

  validates :amount, numericality: true
  validates :paid_at, :amount, presence: true
  validate do
    errors.add(:base, :duplicate) if duplicates.exists?
  end

  scope :ordered, -> { order(paid_at: :DESC) }
  scope :recent, -> { where(arel_table[:paid_at].gt(3.months.ago)) }

  attr_accessor :skip_generate_journal_entry

  delegate :accounting_settings, to: :organisation

  after_create :confirm!, if: :confirm?
  after_destroy :recalculate_invoice
  after_save :recalculate_invoice
  after_save :generate_journal_entry!, if: :generate_journal_entry?

  before_validation do
    self.booking = invoice&.booking || booking
  end

  def duplicates
    Payment.where(booking:, paid_at:, amount:, camt_instr_id:, invoice_id:)
           .where.not(id: [id])
  end

  def confirm!
    return if write_off || !confirm?

    context = { payment: self }
    MailTemplate.use(:payment_confirmation_notification, booking, to: :tenant, context:, &:autodeliver!)
  end

  def generate_journal_entry?
    organisation.accounting_settings.enabled && !skip_generate_journal_entry
  end

  def generate_journal_entry!
    return unless accounting_settings.enabled && accounting_settings.payment_account_nr.present?

    existing_ids = organisation.journal_entries.where(payment: self).pluck(:id)
    new_journal_entry = JournalEntry::Factory.new.payment(self)

    # raise ActiveRecord::Rollback unless
    new_journal_entry.save! && organisation.journal_entries.where(id: existing_ids).destroy_all
    journal_entries.reload
  end

  def recalculate_invoice
    return if invoice.blank?

    invoice.recalculate
    invoice.save if invoice.amount_open_changed?
  end
end
