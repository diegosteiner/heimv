class Contract < ApplicationRecord
  belongs_to :booking

  after_save do
    booking.state_transition
  end

  before_save :oust

  def oust
    return unless was_sent? && (changed & %w[text sent_at]).any?

    new_contract = dup
    new_contract.update!(valid_from: Time.zone.now, sent_at: nil, signed_at: nil)
    restore_attributes
    assign_attributes(valid_until: new_contract.valid_from)
  end

  def filename
    "#{self.class.model_name.human}_#{booking.ref}_#{id}"
  end

  scope :sent, -> { where.not(sent_at: nil) }
  scope :signed, -> { where.not(signed_at: nil) }

  def html_body
    markdown_service.html_body(body_interpolation_arguments)
  end

  def text_body
    markdown_service.text_body(body_interpolation_arguments)
  end

  # rubocop:disable Metrics/AbcSize
  def body_interpolation_arguments
    {
      ref: booking.ref,
      begins_at: booking.occupancy.begins_at,
      ends_at: booking.occupancy.ends_at,
      home: booking.home,
      tenant: booking.tenant.to_s,
      janitor: booking.home.janitor&.lines&.join(', ')
    }
  end
  # rubocop:enable Metrics/AbcSize

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
