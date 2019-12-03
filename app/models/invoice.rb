# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  deleted_at         :datetime
#  invoice_type       :integer
#  issued_at          :datetime
#  paid               :boolean          default(FALSE)
#  payable_until      :datetime
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
#  index_invoices_on_booking_id  (booking_id)
#  index_invoices_on_ref         (ref)
#  index_invoices_on_type        (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices, touch: true
  has_many :invoice_parts, -> { order(position: :asc) }, inverse_of: :invoice, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_one_attached :pdf
  has_one :organisation, through: :booking

  enum invoice_type: { invoice: 0, deposit: 1, late_notice: 2 }

  scope :ordered, -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :present, -> { where(deleted_at: nil) }
  scope :unpaid,  -> { present.where(paid: false) }
  scope :paid,    -> { present.where(paid: true) }
  scope :sent,    -> { present.where.not(sent_at: nil) }
  scope :unsent,  -> { present.where(sent_at: nil) }
  scope :overdue, ->(at = Time.zone.today) { present.where(arel_table[:payable_until].lteq(at)) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :set_paid
  before_save :generatate_pdf
  after_touch :recalculate_amount

  def generatate_pdf
    self.pdf = {
      io: StringIO.new(Export::Pdf::Invoice.new(self).build.render),
      filename: filename,
      content_type: 'application/pdf'
    }
  end

  def ref
    @ref ||= invoice_ref_strategy.generate(self) unless new_record?
  end

  def recalculate_amount
    update(amount: invoice_parts.reduce(0) { |result, invoice_part| invoice_part.inject_self(result) })
  end

  def filename
    "#{self.class.human_enum(:invoice_types, invoice_type)}_#{booking.ref}_#{id}.pdf"
  end

  def address
    @address ||= Address.new(organisation: booking.tenant_organisation, name: booking.tenant.name,
                              street_address: booking.tenant.street_address, zipcode: booking.tenant.zipcode,
                              place: booking.tenant.place, country_code: 'CH')
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

  def to_s
    invoice_ref_strategy.format_ref(ref)
  end

  def invoice_ref_strategy
    @invoice_ref_strategy ||= organisation.invoice_ref_strategy
  end
end
