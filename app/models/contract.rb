# == Schema Information
#
# Table name: contracts
#
#  id          :bigint(8)        not null, primary key
#  booking_id  :uuid
#  sent_at     :date
#  signed_at   :date
#  text        :text
#  valid_from  :datetime
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Contract < ApplicationRecord
  belongs_to :booking
  has_one_attached :pdf

  scope :valid, -> { where(valid_until: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :ordered, -> { order(valid_from: :asc) }

  after_save do
    booking.state_transition
  end

  before_save :oust
  after_save :generatate_pdf

  def generatate_pdf
    pdf.attach(
      io: StringIO.new(Export::Pdf::Contract.new(self).build.render),
      filename: filename,
      content_type: 'application/pdf'
    )
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

  def markdown_service
    @markdown_service ||= MarkdownService.new(text)
  end
end
