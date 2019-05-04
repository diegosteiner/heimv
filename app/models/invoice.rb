# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint(8)        not null, primary key
#  booking_id         :uuid
#  issued_at          :datetime
#  payable_until      :datetime
#  sent_at            :datetime
#  text               :text
#  invoice_type       :integer
#  esr_number         :string
#  amount             :decimal(, )      default(0.0)
#  paid               :boolean          default(FALSE)
#  print_payment_slip :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices, touch: true
  has_many :invoice_parts, -> { order(position: :asc) }, inverse_of: :invoice, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_one_attached :pdf

  enum invoice_type: %i[invoice deposit late_notice]

  scope :present, -> { where(deleted_at: nil) }
  scope :unpaid,  -> { present.where(paid: false) }
  scope :paid,    -> { present.where(paid: true) }
  scope :sent,    -> { present.where.not(sent_at: nil) }
  scope :unsent,  -> { present.where(sent_at: nil) }
  scope :overdue, ->(at = Time.zone.today) { present.where(arel_table[:payable_until].lteq(at)) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :set_paid
  after_touch :recalculate_amount
  after_save :generatate_pdf

  def generatate_pdf
    pdf.attach(
      io: StringIO.new(Export::Pdf::Invoice.new(self).build.render),
      filename: filename,
      content_type: 'application/pdf'
    )
  end

  def ref
    @ref ||= RefService.new.call(self) unless new_record?
  end

  def recalculate_amount
    update(amount: invoice_parts.reduce(0) { |result, invoice_part| invoice_part.inject_self(result) })
  end

  def filename
    "#{self.class.human_enum(:invoice_types, invoice_type)}_#{booking.ref}_#{id}.pdf"
  end

  def payment_slip_code
    ref
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

  def deleted?
    deleted_at.present?
  end
end
