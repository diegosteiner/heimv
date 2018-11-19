class Message < ApplicationRecord
  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking
  belongs_to :markdown_template, optional: true

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
    template = MarkdownTemplate.find_by(interpolatable_type: Message.to_s, key: key, locale: I18n.locale)
    return nil unless template

    new(attributes) do |message|
      message.subject = template.title
      message.markdown = Interpolator.new(message).interpolate(template.to_markdown)
    end
  end
end
