# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id          :bigint           not null, primary key
#  sent_at     :date
#  signed_at   :date
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :uuid
#
# Indexes
#
#  index_contracts_on_booking_id  (booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class Contract < ApplicationRecord
  belongs_to :booking, inverse_of: :contracts, touch: true
  has_one_attached :pdf
  has_one_attached :signed_pdf

  scope :valid, -> { where(valid_until: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :ordered, -> { order(valid_from: :asc) }

  before_save :oust, :generatate_pdf, :set_signed_at
  after_save do
    booking.state_transition
  end

  def generatate_pdf
    self.pdf = {
      io: StringIO.new(Export::Pdf::ContractPdf.new(self).render_document),
      filename: filename,
      content_type: 'application/pdf'
    }
  end

  def oust
    return unless was_sent? && (changed & %w[text]).any?

    new_contract = dup
    new_contract.update!(valid_from: Time.zone.now, sent_at: nil, signed_at: nil)
    restore_attributes
    assign_attributes(valid_until: new_contract.valid_from)
  end

  def filename
    "#{self.class.model_name.human}_#{booking.ref}_#{id}.pdf"
  end

  scope :sent, -> { where.not(sent_at: nil) }
  scope :signed, -> { where.not(signed_at: nil) }

  def html_body
    markdown_service.html_body(body_interpolation_arguments)
  end

  def text_body
    markdown_service.text_body(body_interpolation_arguments)
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

  def ousted?
    valid_until.present?
  end

  private

  def set_signed_at
    self.signed_at ||= Time.zone.now if signed_pdf.attached?
  end

  def markdown_service
    @markdown_service ||= MarkdownService.new(text)
  end
end
