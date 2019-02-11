class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices, touch: true
  has_many :invoice_parts, -> { order(position: :ASC) }, inverse_of: :invoice, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_one_attached :pdf

  enum invoice_type: %i[invoice deposit late_notice]

  scope :unpaid,  -> { where(paid: false) }
  scope :paid,    -> { where(paid: true) }
  scope :sent,    -> { where.not(sent_at: nil) }
  scope :unsent,  -> { where(sent_at: nil) }
  scope :overdue, ->(at = Time.zone.today) { where(arel_table[:payable_until].lteq(at)) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :set_paid
  after_touch :recalculate_amount
  after_save :generatate_pdf

  def generatate_pdf
    pdf.attach(
      io: StringIO.new(Pdf::Invoice.new(self).build.render),
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
end
