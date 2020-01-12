# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("manager"), not null
#  body                 :text
#  sent_at              :datetime
#  subject              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  markdown_template_id :bigint
#
# Indexes
#
#  index_messages_on_booking_id            (booking_id)
#  index_messages_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

class Message < ApplicationRecord
  belongs_to :booking, inverse_of: :messages
  has_one :tenant, through: :booking
  belongs_to :markdown_template, optional: true
  has_many_attached :attachments

  attribute :cc, default: []

  enum addressed_to: { manager: 0, tenant: 1, booking_agent: 2 }, _prefix: true

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

  def deliver
    yield(self) if block_given?
    deliverable? && action_mailer_mail.deliver_now && update(sent_at: Time.zone.now)
  end

  def action_mailer_mail
    @action_mailer_mail ||= BookingMailer.booking_message(self)
  end

  def subject
    "#{super} [#{booking.ref}]"
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

    [booking.organisation.email]
  end
end
