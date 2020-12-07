# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  discarded_at       :datetime
#  issued_at          :datetime
#  paid               :boolean          default(FALSE)
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
  include Discard::Model

  belongs_to :booking, inverse_of: :invoices, touch: true
  has_many :invoice_parts, -> { order(position: :asc) }, inverse_of: :invoice, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_one_attached :pdf
  has_one :organisation, through: :booking

  scope :ordered, -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :unpaid,  -> { kept.where(paid: false) }
  scope :paid,    -> { kept.where(paid: true) }
  scope :sent,    -> { kept.where.not(sent_at: nil) }
  scope :unsent,  -> { kept.where(sent_at: nil) }
  scope :overdue, ->(at = Time.zone.today) { kept.where(arel_table[:payable_until].lteq(at)) }
  scope :of, ->(booking) { where(booking: booking) }
  scope :with_default_includes, -> { includes(%i[invoice_parts payments organisation]) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :set_amount, :set_paid
  before_update :generate_pdf, if: :generate_pdf?
  after_create { generate_ref? && generate_ref && save }

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

  def set_amount
    self.amount = invoice_parts.sum(&:amount)
  end

  def amount_in_cents
    (amount * 100).to_i
  end

  def recalculate!
    set_amount
    set_paid
    save
  end

  def filename
    "#{self.class.model_name.human} #{booking.ref}_#{id}.pdf"
  end

  def address_lines
    @address_lines ||= booking.invoice_address&.lines.presence || booking.tenant&.address_lines || []
  end

  def amount_open
    amount - amount_paid
  end

  def amount_paid
    payments.sum(&:amount)
  end

  def set_paid
    self.paid = amount_open.zero?
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def to_s
    invoice_ref_strategy.format_ref(ref)
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
    usages = booking.usages.includes(:tarif).where.not(id: invoice_parts.map(&:usage_id))
    usages.map do |usage|
      InvoiceParts::Add.new(
        apply: apply_invoice_part?(usage),
        usage: usage, label: usage.tarif.label, breakdown: usage.breakdown,
        position: usage.tarif.position, amount: usage.price
      )
    end
  end

  def apply_invoice_part?(usage)
    tarif_invoice_type = usage.tarif.invoice_type
    new_record? && tarif_invoice_type.present? && type.to_s == tarif_invoice_type
  end
end
