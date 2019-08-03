# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  booking_id           :uuid
#  markdown_template_id :bigint
#  sent_at              :datetime
#  subject              :string
#  body                 :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Message < ApplicationRecord
  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking
  belongs_to :markdown_template, optional: true
  has_many_attached :attachments

  attribute :cc, default: []
  attribute :bcc, default: []

  enum addressed_to: %i[manager tenant booking_agent], _prefix: true

  validates :to, presence: true

  def to
    @to ||= resolve_addressed_to
  end

  def markdown
    @markdown ||= Markdown.new(body)
  end

  def markdown=(value)
    self.body = value.body
    @markdown = value
  end

  def deliverable?
    valid? && (booking.messages_enabled? || addressed_to_manager?)
  end

  def deliver_now
    # raise "och"
    deliverable? && action_mailer_mail.deliver_now && update(sent_at: Time.zone.now)
  end

  def action_mailer_mail
    @action_mailer_mail ||= BookingMailer.booking_message(self)
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

  protected

  def resolve_addressed_to
    return [booking.email].compact if addressed_to_tenant?
    return [booking.booking_agent&.email].compact if addressed_to_booking_agent?

    [ENV.fetch('ADMIN_EMAIL', 'info@heimverwalung.example.com')]
  end
end
