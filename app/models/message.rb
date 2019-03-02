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

  def deliver_now
    yield(self) if block_given?
    save && message_delivery.deliver_now && update(sent_at: Time.zone.now)
  end

  def message_delivery
    BookingMailer.booking_message(self)
  end

  def self.new_from_template(template, attributes = {})
    new_from_template!(template, attributes)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.new_from_template!(template, attributes = {})
    template = MarkdownTemplate.find_by!(key: template) unless template.is_a?(MarkdownTemplate)

    new(attributes) do |message|
      message.markdown_template = template
      message.subject = template.title
      message.markdown = template.interpolate('booking' => message.booking)
    end
  end
end
