# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  amount_open        :decimal(, )
#  discarded_at       :datetime
#  issued_at          :datetime
#  payable_until      :datetime
#  payment_info_type  :string
#  print_payment_slip :boolean          default(FALSE)
#  ref                :string
#  sent_at            :datetime
#  text               :text
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#
# Indexes
#
#  index_invoices_on_booking_id    (booking_id)
#  index_invoices_on_discarded_at  (discarded_at)
#  index_invoices_on_ref           (ref)
#  index_invoices_on_type          (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class Invoice < ApplicationRecord
  include Subtypeable
  include Discard::Model

  belongs_to :booking, inverse_of: :invoices, touch: true
  has_many :invoice_parts, -> { ordered }, inverse_of: :invoice, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_one_attached :pdf
  has_one :organisation, through: :booking

  scope :ordered,  -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :unpaid,   -> { kept.where(arel_table[:amount_open].gt(0)) }
  scope :open,     -> { kept.where.not(arel_table[:amount_open].eq(0)) }
  scope :overpaid, -> { kept.where(arel_table[:amount_open].lt(0)) }
  scope :paid,     -> { kept.where(arel_table[:amount_open].lteq(0)) }
  scope :sent,     -> { kept.where.not(sent_at: nil) }
  scope :unsent,   -> { kept.where(sent_at: nil) }
  scope :overdue,  ->(at = Time.zone.today) { kept.where(arel_table[:payable_until].lteq(at)) }
  scope :of,       ->(booking) { where(booking: booking) }
  scope :with_default_includes, -> { includes(%i[invoice_parts payments organisation]) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :recalculate
  before_update :generate_pdf, if: :generate_pdf?
  after_create { generate_ref? && generate_ref && save }
  after_save { booking.transition_to }
  delegate :invoice_address_lines, to: :booking

  def generate_pdf?
    ref.present? && (pdf.blank? || changed?)
  end

  def generate_ref?
    ref.blank?
  end

  def generate_pdf
    self.pdf = {
      io: StringIO.new(Export::Pdf::InvoicePdf.new(self).render_document),
      filename: filename,
      content_type: 'application/pdf'
    }
  end

  def generate_ref
    self.ref = invoice_ref_strategy.generate(self)
  end

  def amount_in_cents
    (amount * 100).to_i
  end

  def paid?
    overpaid? || amount_open.zero?
  end

  def sent?
    sent_at.present?
  end

  def open?
    !amount_open.zero?
  end

  def overpaid?
    amount_open.negative?
  end

  def recalculate
    self.amount = invoice_parts.ordered.inject(0) { |sum, invoice_part| invoice_part.to_sum(sum) }
    self.amount_open = amount - amount_paid
  end

  def recalculate!
    recalculate
    save
  end

  def filename
    "#{self.class.model_name.human} #{booking.ref}_#{id}.pdf"
  end

  def amount_paid
    payments.sum(&:amount)
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def formatted_ref
    invoice_ref_strategy.format_ref(ref)
  end

  def to_s
    "#{booking.ref} - #{formatted_ref}"
  end

  def invoice_ref_strategy
    @invoice_ref_strategy ||= organisation.invoice_ref_strategy
  end

  def payment_info
    @payment_info ||= PaymentInfos.const_get(payment_info_type).new(self) if payment_info_type.present?
  end

  def to_liquid
    Manage::InvoiceSerializer.render_as_hash(self).deep_stringify_keys
  end

  def suggested_invoice_parts
    usages = booking.usages.tenant_visible.where.not(id: invoice_parts.map(&:usage_id))
    usages.map do |usage|
      InvoiceParts::Add.from_usage(usage, apply: apply_invoice_part?(usage))
    end
  end

  def apply_invoice_part?(usage)
    tarif_invoice_type = usage.tarif.invoice_type
    new_record? && tarif_invoice_type.present? && type.to_s == tarif_invoice_type
  end
end
