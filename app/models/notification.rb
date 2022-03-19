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
  RichTextTemplate.require_template(:notification_footer, context: %i[booking], required_by: self)

  belongs_to :booking, inverse_of: :notifications
  belongs_to :rich_text_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking

  enum addressed_to: { manager: 0, tenant: 1, booking_agent: 2 }, _prefix: true
  validates :to, presence: true
  validates :rich_text_template, presence: true, if: :rich_text_template_key?

  delegate :bcc, to: :organisation
  delegate :locale, to: :booking
  delegate :attach, to: :attachments

  attribute :rich_text_template_key
  attribute :context

  scope :failed, -> { where(queued_for_delivery: true, sent_at: nil).where(arel_table[:created_at].lt(1.hour.ago)) }

  before_validation do
    apply_template(resolve_template)
  end

  def deliverable?
    valid? && organisation.notifications_enabled? && (booking.notifications_enabled? || addressed_to_manager?)
  end

  def queue_for_delivery
    deliverable? && update(queued_for_delivery: true)
  end

  def deliver
    return false unless deliverable?

    queue_for_delivery && invoke_mailer && update(sent_at: Time.zone.now)
  end

  def prepare_attachments_for_mail
    attachments.to_h { |attachment| [attachment.filename.to_s, attachment.blob.download] }
  end

  def resolve_template
    return if rich_text_template_key.blank? || organisation.blank? || booking.blank?

    organisation.rich_text_templates.enabled.by_key(rich_text_template_key, home_id: booking.home_id)
  end

  def apply_template(rich_text_template)
    return if rich_text_template.blank?

    self.rich_text_template = rich_text_template
    I18n.with_locale(booking.locale) do
      interpolation_result = rich_text_template.interpolate(context)
      self.subject = interpolation_result.title
      self.body = interpolation_result.body
    end
  end

  def locale
    (addressed_to_tenant? && booking&.locale) ||
      (addressed_to_manager? && organisation&.locale) ||
      I18n.locale
  end

  def template=(rich_text_template_or_key)
    if rich_text_template_or_key.is_a?(Symbol) || rich_text_template_or_key.is_a?(String)
      self.rich_text_template_key = rich_text_template_or_key
    else
      self.rich_text_template = rich_text_template_or_key
    end
  end

  def footer
    organisation.rich_text_templates.enabled.by_key(:notification_footer)&.interpolate(context)&.body
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

  # rubocop:disable Metrics/MethodLength
  def to=(value)
    super case value
          when Tenant, Booking
            self.addressed_to = :tenant
            [value.email]
          when Operator, Organisation
            self.addressed_to = :manager
            [value.email]
          when BookingAgent
            self.addressed_to = :booking_agent
            [value.email]
          else
            [value&.to_s].flatten.compact
          end
  end
  # rubocop:enable Metrics/MethodLength

  protected

  def invoke_mailer!
    organisation.mailer.mail(to: to, subject: subject, cc: cc, bcc: bcc, body: text,
                             html_body: body, attachments: prepare_attachments_for_mail)
  end

  def invoke_mailer
    invoke_mailer!
    true
  rescue Net::SMTPFatalError, Net::SMTPAuthenticationError => e
    Rails.logger.error(e.message)
    # defined?(Sentry) && Sentry.with_scope do |scope|
    #   scope.set_tags(booking: booking.id)
    #   Sentry.capture_exception(e)
    # end
    false
  end
end
