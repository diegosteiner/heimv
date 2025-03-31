# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                        :bigint           not null, primary key
#  locale                    :string
#  sent_at                   :date
#  signed_at                 :date
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

  scope :valid, -> { where(valid_until: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :ordered, -> { order(valid_from: :asc) }
  scope :signed, -> { where.not(signed_at: nil) }

  before_save :supersede, :set_signed_at
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
    return unless was_sent? && changed.intersect?(%w[text])

    successor = dup
    successor.update!(**attributes, valid_from: Time.zone.now, sent_at: nil, signed_at: nil)
    restore_attributes
    assign_attributes(valid_until: successor.valid_from)
  end

  def filename
    "#{self.class.model_name.human}_#{Time.zone.today}_#{booking.ref}_#{id}.pdf"
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def signed!
    update(signed_at: Time.zone.now)
  end

  def sent?
    sent_at.present?
  end

  def was_sent?
    sent_at_was.present?
  end

  def signed?
    signed_at.present?
  end

  def superseded?
    valid_until.present?
  end

  def usages
    @usages ||= booking&.usages&.select do |usage|
      usage.tarif.associated_types.include?(Tarif::ASSOCIATED_TYPES.key(self.class))
    end
  end

  def to_attachable
    { io: StringIO.new(pdf.blob.download), filename:, content_type: pdf.content_type } if pdf&.blob.present?
  end

  private

  def set_signed_at
    self.signed_at ||= Time.zone.now if signed_pdf.attached?
  end
end
