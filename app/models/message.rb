class Message < ApplicationRecord
  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking
  belongs_to :markdown_template, optional: true
  has_many_attached :attachments

  def to
    [booking.email]
  end

  def markdown
    @markdown ||= Markdown.new(body)
  end

  def markdown=(value)
    self.body = value.body
    @markdown = value
  end

  def save_and_deliver_now
    save && message_delivery.deliver_now && update(sent_at: Time.zone.now)
  end

  def message_delivery
    BookingMailer.booking_message(self)
  end

  def self.new_from_template(key, attributes = {})
    template = MarkdownTemplate.find_by_key(key)
    return nil unless template

    new(attributes) do |message|
      message.subject = template.title
      message.markdown = template.interpolate(booking)
    end
  end
end
