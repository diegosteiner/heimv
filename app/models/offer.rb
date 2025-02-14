class Offer < ApplicationRecord
  locale_enum default: I18n.locale
  delegate :currency, to: :organisation

  belongs_to :booking, inverse_of: :invoices, touch: true
  belongs_to :supersede_invoice, class_name: :Invoice, optional: true, inverse_of: :superseded_by_invoices

  has_many :invoice_parts, -> { ordered }, inverse_of: :invoice, dependent: :destroy
  has_many :superseded_by_invoices, class_name: :Invoice, dependent: :nullify,
                                    foreign_key: :supersede_invoice_id, inverse_of: :supersede_invoice
  has_many :payments, dependent: :nullify
  has_many :journal_entries, -> { ordered }, dependent: :nullify, inverse_of: :invoice

  has_one :organisation, through: :booking
  has_one_attached :pdf

  enum :status, { draft: 0, sent: 1, paid: 2, archived: 3 }

  attr_accessor :skip_generate_pdf, :skip_journal_entries

  scope :ordered, -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :unpaid, lambda {
    kept.where(status: :sent).where.not(type: 'Invoices::Offer').where.not(arel_table[:amount_open].eq(0))
  }
  scope :paid, -> { kept.where(arel_table[:amount_open].eq(0)) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { kept.where(sent_at: nil) }
  scope :overdue, ->(at = Time.zone.today) { kept.where(status: :sent).where(arel_table[:payable_until].lteq(at)) }
  scope :of, ->(booking) { where(booking:) }
  scope :with_default_includes, -> { includes(%i[invoice_parts payments organisation]) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true

  before_save :sequence_number, :generate_ref, :generate_payment_ref, :recalculate, :set_status
  before_save :generate_pdf, if: :generate_pdf?
  after_create :supersede!
  after_save :recalculate!, :update_payments
  after_save :update_journal_entries, unless: :skip_journal_entries

  validates :type, inclusion: { in: ->(_) { Invoice.subtypes.keys.map(&:to_s) } }

  def generate_pdf?
    kept? && !skip_generate_pdf && (changed? || pdf.blank?)
  end

  def sequence_number
    self[:sequence_number] ||= organisation.key_sequences.key(Offer.sti_name, year: sequence_year).lease!
  end

  def sequence_year
    self[:sequence_year] ||= created_at&.year || Time.zone.today.year
  end

  def generate_pdf
    I18n.with_locale(locale || I18n.locale) do
      self.pdf = { io: StringIO.new(Export::Pdf::OfferPdf.new(self).render_document),
                   filename:, content_type: 'application/pdf' }
    end
  end

  def generate_ref(force: false)
    self.ref = RefBuilders::Offer.new(self).generate if ref.blank? || force
  end

  def amount
    invoice_parts.inject(0) { |sum, invoice_part| invoice_part.to_sum(sum) }
  end

  def filename
    "#{self.class.model_name.human} #{ref}.pdf"
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def to_s
    ref
  end

  def suggested_invoice_parts
    ::InvoicePart::Factory.new(self).build
  end

  def invoice_address
    @invoice_address ||= InvoiceAddress.new(booking)
  end

  def to_attachable
    { io: StringIO.new(pdf.blob.download), filename:, content_type: pdf.content_type } if pdf&.blob.present?
  end

  def vat_breakdown
    invoice_parts.group_by(&:vat_category).except(nil).transform_values { _1.sum(&:calculated_amount) }
  end

  def template_context
    TemplateContext.new(invoice: self, booking:, costs: CostEstimation.new(booking), organisation:)
  end
end
