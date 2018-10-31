class Message < ApplicationRecord
  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking

  def to
    [booking.email]
  end

  def to_markdown
    MardownService::Markdown.new(body)
  end

  def mail
    BookingStateMailer.booking_message(self)
    # sent_at: Time.zone.now)
  end

  def self.new_from_template(*keys)
    template = MarkdownTemplate.find_by(key: MarkdownTemplate.composite_key(*keys), locale: I18n.locale)
    return unless template

    new do |message|
      message.subject = template.title
      message.body = template.interpolate(booking)
    end
  end
end
