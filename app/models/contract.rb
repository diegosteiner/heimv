class Contract < ApplicationRecord
  belongs_to :booking
  belongs_to :successor, class_name: :Contract, optional: true
  has_one :predecessor, class_name: :Contract

  after_save do
    booking.state_transition
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
      tenant: booking.customer.to_s,
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
