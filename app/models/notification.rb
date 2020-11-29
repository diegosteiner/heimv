# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("manager"), not null
#  body                 :text
#  cc                   :string           default([]), is an Array
#  queued_for_delivery  :boolean          default(FALSE)
#  sent_at              :datetime
#  subject              :string
#  to                   :string           default([]), is an Array
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  markdown_template_id :bigint
#
# Indexes
#
#  index_notifications_on_booking_id            (booking_id)
#  index_notifications_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

class Notification < ApplicationRecord
  belongs_to :booking, inverse_of: :notifications
  belongs_to :markdown_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking

  enum addressed_to: { manager: 0, tenant: 1, booking_agent: 2 }, _prefix: true
  validates :to, presence: true
  validates :markdown_template, presence: true, if: :from_template?
  attribute :from_template
  delegate :bcc, to: :organisation
  delegate :locale, to: :booking
  attribute :context

  before_validation do
    self.to = to.presence || resolve_addressed_to
    self.markdown_template ||= resolve_markdown_template
  end

  def markdown
    @markdown ||= Markdown.new(body)
  end

  def markdown=(value)
    self.body = value.body
    @markdown = value
  end

  def deliverable?
    valid? && organisation.notifications_enabled? && (booking.notifications_enabled? || addressed_to_manager?)
  end

  def queue_for_delivery
    deliverable? && update(queued_for_delivery: true)
  end

  def deliver
    return save unless deliverable?

    queue_for_delivery && invoke_mailer! && update(sent_at: Time.zone.now)
  end

  def attachments_for_mail
    Hash[attachments.map { |attachment| [attachment.filename.to_s, attachment.blob.download] }]
  end

  def resolve_markdown_template
    return if from_template.blank? || organisation.blank? || booking.blank?

    organisation.markdown_templates.by_key(from_template)
  end

  def locale
    (addressed_to_tenant? && booking&.locale) ||
      (addressed_to_manager? && organisation&.locale) ||
      I18n.locale
  end

  def markdown_template=(markdown_template)
    super
    return unless markdown_template.is_a?(MarkdownTemplate)

    Mobility.with_locale(booking.locale) do
      self.subject = markdown_template.interpolate_title(context)
      self.markdown = markdown_template.interpolate(context)
    end
  end

  def context
    super || { 'booking' => booking }
  end

  protected

  def resolve_addressed_to
    return [booking.email].compact if addressed_to_tenant?
    return [booking.booking_agent&.email].compact if addressed_to_booking_agent?

    [booking.organisation.email]
  end

  def invoke_mailer!
    organisation.mailer.mail(to: to, subject: subject, cc: cc, bcc: bcc,
                             body: markdown.to_text, html_body: markdown.to_html,
                             attachments: attachments_for_mail)
  rescue Net::SMTPFatalError, Net::SMTPAuthenticationError => e
    defined?(Raven) && Raven.capture_exception(e) || Rails.logger.warn(e.message)
    false
  end
end
