class Message < ApplicationRecord
  attr_accessor :markdown

  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking

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

  def self.new_from_template(key, interpolator = nil, attributes = {})
    template = MarkdownTemplate.find_by(interpolatable_type: Message.to_s, key: key, locale: I18n.locale)

    new(attributes) do |message|
      if template
        message.subject = template.title
        message.markdown = interpolator&.interpolate(template.to_markdown)
      end
    end
  end
end
