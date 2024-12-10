# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                   :bigint           not null, primary key
#  amount               :decimal(, )      default(0.0)
#  amount_open          :decimal(, )
#  discarded_at         :datetime
#  issued_at            :datetime
#  locale               :string
#  payable_until        :datetime
#  payment_info_type    :string
#  payment_required     :boolean          default(TRUE)
#  ref                  :string
#  sent_at              :datetime
#  text                 :text
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  supersede_invoice_id :bigint
#
# Indexes
#
#  index_invoices_on_booking_id            (booking_id)
#  index_invoices_on_discarded_at          (discarded_at)
#  index_invoices_on_ref                   (ref)
#  index_invoices_on_supersede_invoice_id  (supersede_invoice_id)
#  index_invoices_on_type                  (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (supersede_invoice_id => invoices.id)
#

class Invoice < ApplicationRecord
  include Subtypeable
  include Discard::Model

  locale_enum default: I18n.locale

  belongs_to :booking, inverse_of: :invoices, touch: true
  belongs_to :supersede_invoice, class_name: :Invoice, optional: true, inverse_of: :superseded_by_invoices

  has_many :invoice_parts, -> { ordered }, inverse_of: :invoice, dependent: :destroy
  has_many :superseded_by_invoices, class_name: :Invoice, dependent: :nullify,
                                    foreign_key: :supersede_invoice_id, inverse_of: :supersede_invoice
  has_many :payments, dependent: :nullify

  has_one :organisation, through: :booking
  has_one_attached :pdf

  attr_accessor :skip_generate_pdf

  scope :ordered,   -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :unpaid,    -> { kept.where(arel_table[:amount_open].gt(0)) }
  scope :unsettled, -> { kept.where.not(type: 'Invoices::Offer').where.not(arel_table[:amount_open].eq(0)) }
  scope :refund,    -> { kept.where(arel_table[:amount_open].lt(0)) }
  scope :paid,      -> { kept.where(arel_table[:amount_open].lteq(0)) }
  scope :sent,      -> { where.not(sent_at: nil) }
  scope :unsent,    -> { kept.where(sent_at: nil) }
  scope :overdue,   ->(at = Time.zone.today) { kept.where(arel_table[:payable_until].lteq(at)) }
  scope :of,        ->(booking) { where(booking:) }
  scope :with_default_includes, -> { includes(%i[invoice_parts payments organisation]) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :recalculate
  # after_create { generate_ref? && generate_ref && save }
  before_create :sequence_number, :build_refs
  after_create :supersede!
  before_update :generate_pdf, if: :generate_pdf?
  after_save :recalculate!

  delegate :currency, to: :organisation

  validates :type, inclusion: { in: ->(_) { Invoice.subtypes.keys.map(&:to_s) } }
  validate do
    errors.add(:supersede_invoice_id, :invalid) if supersede_invoice && supersede_invoice.organisation != organisation
  end

  def generate_pdf?
    kept? && ref.present? && !skip_generate_pdf && (pdf.blank? || changed?)
  end

  def supersede!
    return if supersede_invoice.blank? || supersede_invoice.discarded?

    self.payments = supersede_invoice.payments
    supersede_invoice.discard!
  end

  def sequence_number
    @sequence_number ||= organisation.key_sequences.key(Invoice.sti_name, year: :current).lease!
  end

  def generate_pdf
    I18n.with_locale(locale || I18n.locale) do
      self.pdf = { io: StringIO.new(Export::Pdf::InvoicePdf.new(self).render_document),
                   filename:, content_type: 'application/pdf' }
    end
  end

  # def generate_ref
  #   self.ref = invoice_ref_service.generate(self)
  # end

  def build_refs
    # self.sequence_number ||= organisation.key_sequences.key
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
    self.amount = invoice_parts.ordered.inject(0) { |sum, invoice_part| invoice_part.to_sum(sum) }
    self.amount_open = amount - amount_paid
  end

  def recalculate!
    recalculate
    save! if amount_changed? || amount_open_changed?
  end

  def filename
    "#{self.class.model_name.human} #{booking.ref}_#{id}.pdf"
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

  def formatted_ref
    invoice_ref_service.format_ref(ref)
  end

  def to_s
    "#{booking.ref} - #{formatted_ref}"
  end

  def invoice_ref_service
    @invoice_ref_service ||= InvoiceRefService.new(organisation)
  end

  def payment_info
    @payment_info ||= PaymentInfos.const_get(payment_info_type).new(self) if payment_info_type.present?
  end

  def suggested_invoice_parts
    ::InvoicePart::Factory.new(self).call
  end

  def invoice_address
    @invoice_address ||= InvoiceAddress.new(booking)
  end

  def to_attachable
    { io: StringIO.new(pdf.blob.download), filename:, content_type: pdf.content_type } if pdf&.blob.present?
  end

  def vat_amounts
    invoice_parts.group_by(&:vat_category).except(nil).transform_values { _1.sum(&:calculated_amount) }
  end

  def journal_entries
    [debitor_journal_entry] + invoice_parts.map(&:journal_entries)
  end

  def accounting_ref
    format('HV%05d', id + 1)
  end

  def debitor_journal_entry
    Accounting::JournalEntry.new(
      account: organisation.accounting_settings.debitor_account_nr,
      date: issued_at, amount:, amount_type: :brutto, side: :soll,
      reference: accounting_ref, source: self, currency:, booking:,
      text: "#{self.class.model_name.human} #{accounting_ref} - #{booking.tenant.last_name}"
    )
  end
end
