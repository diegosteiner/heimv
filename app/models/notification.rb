# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                    :bigint           not null, primary key
#  addressed_to          :integer          default("manager"), not null
#  bcc                   :string
#  body                  :text
#  cc                    :string           default([]), is an Array
#  locale                :string           default(NULL), not null
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
  RichTextTemplate.require_template(:notification_footer, template_context: %i[booking], required_by: self)

  belongs_to :booking, inverse_of: :notifications
  belongs_to :rich_text_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking

  locale_enum
  enum addressed_to: { manager: 0, tenant: 1, booking_agent: 2 }, _prefix: true

  validates :to, :locale, presence: true
  validates :rich_text_template, presence: true, if: :rich_text_template_key?

  attribute :rich_text_template_key
  attribute :template_context

  before_validation :apply_template

  def deliverable?
    valid? && organisation.notifications_enabled? && booking.notifications_enabled?
  end

  def deliver
    deliverable? && save && message_delivery.tap(&:deliver_later)
  end

  def delivered?
    sent_at.present?
  end

  def attach(*files_or_documents_to_attach)
    files_or_documents_to_attach.flatten.map do |attachment|
      next attachment.attach_to(attachments) if attachment.is_a?(DesignatedDocument)
      next attachments.attach(attachment.blob) if attachment.respond_to?(:blob) && attachment.blob.present?

      attachments.attach(attachment)
    end
  end

  def resolve_template
    return if rich_text_template_key.blank? || organisation.blank? || booking.blank?

    organisation.rich_text_templates.enabled.by_key(rich_text_template_key)
  end

  def apply_template(rich_text_template = resolve_template)
    return if rich_text_template.blank?

    self.rich_text_template = rich_text_template
    I18n.with_locale(locale) do
      interpolation_result = rich_text_template.interpolate(template_context)
      self.subject = interpolation_result.title
      self.body = interpolation_result.body
    end
  end

  def template=(rich_text_template_or_key)
    if rich_text_template_or_key.is_a?(Symbol) || rich_text_template_or_key.is_a?(String)
      self.rich_text_template_key = rich_text_template_or_key
    else
      self.rich_text_template = rich_text_template_or_key
    end
  end

  def footer
    organisation.rich_text_templates.enabled.by_key(:notification_footer)&.interpolate(template_context)&.body
  end

  def template_context
    { booking:, organisation: booking&.organisation, notification: self }.merge(super || {}).stringify_keys
  end

  def text
    ActionView::Base.full_sanitizer.sanitize(html)
  end

  def html
    # rubocop:disable Rails/OutputSafety
    [body, footer].compact_blank.join.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def bcc
    [super, organisation&.bcc].compact
  end

  # rubocop:disable Metrics/MethodLength
  def to=(value)
    value = value.presence
    super case value
          when Tenant, Booking
            self.addressed_to = :tenant
            self.locale = value.locale
            [value.email]
          when Operator, OperatorResponsibility, Organisation
            self.addressed_to = :manager
            self.locale = value.locale
            [value.email]
          when BookingAgent
            self.addressed_to = :booking_agent
            self.locale = value.locale
            [value.email]
          else
            [value&.to_s].flatten.compact
          end
  end
  # rubocop:enable Metrics/MethodLength

  protected

  def message_delivery
    @message_delivery ||= OrganisationMailer.booking_email(self)
  end
end
