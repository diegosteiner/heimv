# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                        :bigint           not null, primary key
#  amount                    :decimal(, )      default(0.0)
#  amount_open               :decimal(, )
#  discarded_at              :datetime
#  issued_at                 :datetime
#  items                     :jsonb
#  locale                    :string
#  payable_until             :datetime
#  payment_info_type         :string
#  payment_ref               :string
#  payment_required          :boolean          default(TRUE)
#  ref                       :string
#  sent_at                   :datetime
#  sequence_number           :integer
#  sequence_year             :integer
#  text                      :text
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  sent_with_notification_id :bigint
#  supersede_invoice_id      :bigint
#

class Invoice < ApplicationRecord
  LIMIT = ENV.fetch('RECORD_LIMIT', 250)

  extend RichTextTemplate::Definition
  include Subtypeable
  include Discard::Model
  include StoreModel::NestedAttributes

  locale_enum default: I18n.locale
  delegate :currency, to: :organisation

  belongs_to :booking, inverse_of: :invoices, touch: true
  belongs_to :supersede_invoice, class_name: :Invoice, optional: true, inverse_of: :superseded_by_invoices
  belongs_to :sent_with_notification, class_name: 'Notification', optional: true

  has_many :superseded_by_invoices, class_name: :Invoice, dependent: :nullify,
                                    foreign_key: :supersede_invoice_id, inverse_of: :supersede_invoice
  has_many :payments, dependent: :nullify
  has_many :journal_entry_batches, -> { ordered }, dependent: :nullify, inverse_of: :invoice

  has_one :organisation, through: :booking
  has_one_attached :pdf

  attr_accessor :skip_generate_pdf, :skip_journal_entry_batches

  attribute :items, Invoice::Item.one_of.to_array_type

  scope :ordered,   -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :not_offer, -> { where.not(type: 'Invoices::Offer') }
  scope :unpaid,    -> { kept.not_offer.where(arel_table[:amount_open].gt(0)) }
  scope :unsettled, -> { kept.not_offer.where.not(arel_table[:amount_open].eq(0)) }
  scope :refund,    -> { kept.not_offer.where(arel_table[:amount_open].lt(0)) }
  scope :paid,      -> { kept.not_offer.where(arel_table[:amount_open].lteq(0)) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent,    -> { kept.where(sent_at: nil) }
  scope :overdue,   ->(at = Time.zone.today) { kept.not_offer.where(arel_table[:payable_until].lteq(at)) }
  scope :of,        ->(booking) { where(booking:) }
  scope :with_default_includes, -> { includes(%i[payments organisation]) }

  accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

  before_save :sequence_number, :generate_ref, :generate_payment_ref, :recalculate
  before_save :generate_pdf, if: :generate_pdf?
  before_save do
    self.items = items&.filter { it.present? && (!it.suggested || it.apply) }
  end
  after_create :supersede!
  after_save :recalculate!, :update_payments
  after_save :update_journal_entry_batches, unless: :skip_journal_entry_batches

  validates :type, inclusion: { in: ->(_) { Invoice.subtypes.keys.map(&:to_s) } }
  validate do
    errors.add(:supersede_invoice_id, :invalid) if supersede_invoice && supersede_invoice.organisation != organisation
  end

  def items
    super || []
  end

  def generate_pdf?
    kept? && !skip_generate_pdf && (changed? || pdf.blank?)
  end

  def supersede!
    return if supersede_invoice.blank? || supersede_invoice.discarded?

    self.payments = supersede_invoice.payments
    supersede_invoice.discard!
  end

  def update_payments
    payments.each { it.update!(booking_id:) }
  end

  def sequence_number
    self[:sequence_number] ||= organisation.key_sequences.key(::Invoice.sti_name, year: sequence_year).lease!
  end

  def sequence_year
    self[:sequence_year] ||= created_at&.year || Time.zone.today.year
  end

  def generate_pdf
    I18n.with_locale(locale || I18n.locale) do
      self.pdf = { io: StringIO.new(Export::Pdf::InvoicePdf.new(self).render_document),
                   filename:, content_type: 'application/pdf' }
    end
  end

  def generate_ref(force: false)
    self.ref = RefBuilders::Invoice.new(self).generate if ref.blank? || force
  end

  def generate_payment_ref
    # this should never be forced
    self.payment_ref = RefBuilders::InvoicePayment.new(self).generate if payment_ref.blank?
  end

  def update_journal_entry_batches(force: false)
    JournalEntryBatches::Invoice.handle(self) if organisation.accounting_settings&.enabled || force
  end

  def paid?
    refund? || amount_open.zero?
  end

  def sent?
    sent_at.present?
  end

  def unsettled?
    !settled?
  end

  def settled?
    amount_open.zero?
  end

  def refund?
    amount_open.negative?
  end

  def recalculate
    self.amount = items.reduce(0) { |sum, item| item.to_sum(sum) } || 0
    self.amount_open = amount - amount_paid
  end

  # TODO: describe why this is needed
  def recalculate!
    recalculate
    save! if amount_changed? || amount_open_changed?
  end

  def filename
    "#{self.class.model_name.human} #{ref}.pdf"
  end

  def amount_paid
    payments.sum(&:amount) || 0
  end

  def percentage_paid
    return 1 if amount.nil? || amount.zero?
    return 0 if amount_paid.zero?

    amount / amount_paid
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def to_s
    ref
  end

  def payment_info
    @payment_info ||= PaymentInfos.const_get(payment_info_type).new(self) if payment_info_type.present?
  end

  def invoice_address
    @invoice_address ||= InvoiceAddress.new(booking)
  end

  def to_attachable
    { io: StringIO.new(pdf.blob.download), filename:, content_type: pdf.content_type } if pdf&.blob.present?
  end

  def vat_breakdown
    items.group_by(&:vat_category).except(nil).transform_values { it.sum(&:calculated_amount) } || {}
  end
end
