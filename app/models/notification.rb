# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                    :bigint           not null, primary key
#  addressed_to          :integer          default("manager"), not null
#  body                  :text
#  cc                    :string           default([]), is an Array
#  queued_for_delivery   :boolean          default(FALSE)
#  sent_at               :datetime
#  subject               :string
#  to                    :string           default([]), is an Array
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_id            :uuid
#  rich_text_template_id :bigint
#
# Indexes
#
#  index_notifications_on_booking_id             (booking_id)
#  index_notifications_on_rich_text_template_id  (rich_text_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (rich_text_template_id => rich_text_templates.id)
#

class Notification < ApplicationRecord
  belongs_to :booking, inverse_of: :notifications
  belongs_to :rich_text_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking

  enum addressed_to: { manager: 0, tenant: 1, booking_agent: 2 }, _prefix: true
  validates :to, presence: true
  validates :rich_text_template, presence: true, if: :from_template?
  attribute :from_template
  delegate :bcc, to: :organisation
  delegate :locale, to: :booking
  attribute :context

  scope :failed, -> { where(queued_for_delivery: true, sent_at: nil).where(arel_table[:created_at].lt(1.hour.ago)) }

  before_validation do
    self.to = to.presence || [resolve_addressed_to]
    self.rich_text_template ||= resolve_rich_text_template
  end

  def deliverable?
    valid? && organisation.notifications_enabled? && (booking.notifications_enabled? || addressed_to_manager?)
  end

  def queue_for_delivery
    deliverable? && update(queued_for_delivery: true)
  end

  def deliver
    return false unless deliverable?

    queue_for_delivery && invoke_mailer! && update(sent_at: Time.zone.now)
  end

  def attachments_for_mail
    attachments.map { |attachment| [attachment.filename.to_s, attachment.blob.download] }.to_h
  end

  def resolve_rich_text_template
    return if from_template.blank? || organisation.blank? || booking.blank?

    organisation.rich_text_templates.by_key(from_template, home_id: booking.home_id)
  end

  def locale
    (addressed_to_tenant? && booking&.locale) ||
      (addressed_to_manager? && organisation&.locale) ||
      I18n.locale
  end

  def rich_text_template=(rich_text_template)
    super
    return unless rich_text_template.is_a?(RichTextTemplate)

    Mobility.with_locale(booking.locale) do
      self.subject = rich_text_template.interpolate_title(context)
      self.body = rich_text_template.interpolate(context)
    end
  end

  def footer
    organisation.rich_text_templates.by_key(:notification_footer)&.interpolate(context)
  end

  def body
    return super.presence&.+(footer) if footer.present?

    super
  end

  def context
    super || { 'booking' => booking }
  end

  def text
    ActionView::Base.full_sanitizer.sanitize(body)
  end

  protected

  def resolve_addressed_to
    return booking.email if addressed_to_tenant?
    return booking.booking_agent&.email&.presence if addressed_to_booking_agent?

    booking.organisation.email.presence
  end

  def invoke_mailer!
    organisation.mailer.mail(to: to, subject: subject, cc: cc, bcc: bcc,
                             body: text, html_body: body,
                             attachments: attachments_for_mail)
    true
  rescue Net::SMTPFatalError, Net::SMTPAuthenticationError => e
    Rails.logger.warn(e.message)
    defined?(Sentry) && Sentry.capture_exception(e)
    false
  end
end
