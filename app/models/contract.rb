class Contract < ApplicationRecord
  belongs_to :booking

  after_save do
    booking.state_transition
  end

  scope :sent, -> { where.not(sent_at: nil) }

  def html_body
    markdown_service.html_body(body_interpolation_arguments)
  end

  def text_body
    markdown_service.text_body(body_interpolation_arguments)
  end

  def body_interpolation_arguments
    {
      ref: booking.ref,
      begins_at: booking.occupancy.begins_at,
      ends_at: booking.occupancy.ends_at,
      home: booking.home,
      tenant: booking.customer.to_s,
      janitor: booking.home.janitor
    }
  end

  def sent?
    sent_at.present?
  end

  def signed?
    signed_at.present?
  end

  private

  def markdown_service
    @markdown_service ||= MarkdownService.new(text)
  end
end
