# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                        :bigint           not null, primary key
#  confirmed_at              :datetime
#  locale                    :string
#  sent_at                   :date
#  tenant_signed_at          :date
#  text                      :text
#  valid_from                :datetime
#  valid_until               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  sent_with_notification_id :bigint
#

class Contract < ApplicationRecord
  extend RichTextTemplate::Definition

  use_template(:contract_text, context: %i[booking])

  locale_enum

  belongs_to :booking, inverse_of: :contracts, touch: true
  belongs_to :sent_with_notification, class_name: 'Notification', optional: true
  has_one :organisation, through: :booking
  has_one_attached :pdf
  has_one_attached :signed_pdf

  attr_accessor :skip_generate_pdf

  validates :signed_pdf, size: { less_than: 5.megabytes },
                         content_type: { in: %w[application/pdf image/jpeg image/png image/gif] }
  validates :pdf, size: { less_than: 5.megabytes }, content_type: { in: %w[application/pdf] }

  scope :valid, -> { where(valid_until: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :ordered, -> { order(valid_from: :asc) }
  scope :tenant_signed, -> { where.not(tenant_signed_at: nil) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  before_save :supersede, :set_tenant_signed_at
  before_save :generate_pdf, if: :generate_pdf?

  def generate_pdf
    I18n.with_locale(locale || I18n.locale) do
      self.pdf = {
        io: StringIO.new(Export::Pdf::ContractPdf.new(self).render_document),
        filename:,
        content_type: 'application/pdf'
      }
    end
  end

  def generate_pdf?
    !skip_generate_pdf && (pdf.blank? || changed?)
  end

  def supersede(**attributes)
    return unless was_sent? && changed.include?('text')

    successor = dup
    successor.update!(**attributes, valid_from: Time.zone.now, sent_at: nil, tenant_signed_at: nil,
                                    confirmed_at: nil)
    restore_attributes
    assign_attributes(valid_until: successor.valid_from)
  end

  def filename
    "#{self.class.model_name.human}_#{Time.zone.today}_#{booking.ref}_#{id}.pdf"
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def tenant_signed!
    update(tenant_signed_at: Time.zone.now)
  end

  def confirmed!
    update(confirmed_at: Time.zone.now)
  end

  def sent?
    sent_at.present?
  end

  def was_sent?
    sent_at_was.present?
  end

  def tenant_signed?
    tenant_signed_at.present?
  end

  def confirmed?
    confirmed_at.present?
  end

  def superseded?
    valid_until.present?
  end

  def usages
    @usages ||= booking&.usages&.select do |usage|
      usage.tarif.associated_types.contract?
    end
  end

  def to_attachable
    { io: StringIO.new(pdf.blob.download), filename:, content_type: pdf.content_type } if pdf&.blob.present?
  end

  private

  def set_tenant_signed_at
    self.tenant_signed_at ||= Time.zone.now if signed_pdf.attached?
  end
end
