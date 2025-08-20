# frozen_string_literal: true

# == Schema Information
#
# Table name: quotes
#
#  id                        :bigint           not null, primary key
#  amount                    :decimal(, )      default(0.0)
#  discarded_at              :datetime
#  issued_at                 :datetime
#  items                     :jsonb
#  locale                    :string
#  ref                       :string
#  sent_at                   :datetime
#  sequence_number           :integer
#  sequence_year             :integer
#  text                      :text
#  valid_until               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  sent_with_notification_id :bigint
#

class Quote < ApplicationRecord
  extend RichTextTemplate::Definition
  include Subtypeable
  include Discard::Model
  include StoreModel::NestedAttributes

  locale_enum default: I18n.locale
  delegate :currency, to: :organisation

  belongs_to :booking, inverse_of: :invoices, touch: true
  belongs_to :sent_with_notification, class_name: 'Notification', optional: true
  has_one :organisation, through: :booking
  has_one_attached :pdf

  attr_accessor :skip_generate_pdf

  attribute :items, Invoice::Item.one_of.to_array_type

  scope :ordered,   -> { order(valid_until: :ASC, created_at: :ASC) }
  scope :sent,      -> { where.not(sent_at: nil) }
  scope :unsent,    -> { kept.where(sent_at: nil) }

  accepts_nested_attributes_for :items, reject_if: :all_blank, allow_destroy: true

  before_save :sequence_number, :generate_ref, :recalculate
  before_save :generate_pdf, if: :generate_pdf?

  validates :items, store_model: true

  def items
    super || self.items = []
  end

  def generate_pdf?
    kept? && !skip_generate_pdf && (changed? || pdf.blank?)
  end

  def sequence_number
    self[:sequence_number] ||= organisation.key_sequences.key(Quote.sti_name, year: sequence_year).lease!
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

  def sent?
    sent_at.present?
  end

  def recalculate
    self.amount = items.reduce(0) { |sum, item| item.to_sum(sum) } || 0
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
