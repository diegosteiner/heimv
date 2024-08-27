# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id               :bigint           not null, primary key
#  body             :text
#  deliver_to       :string           default([]), is an Array
#  delivered_at     :datetime
#  sent_at          :datetime
#  subject          :string
#  to               :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  booking_id       :uuid
#  mail_template_id :bigint
#
# Indexes
#
#  index_notifications_on_booking_id        (booking_id)
#  index_notifications_on_mail_template_id  (mail_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (mail_template_id => rich_text_templates.id)
#

class Notification < ApplicationRecord
  RichTextTemplate.define(:notification_footer, context: %i[booking])

  belongs_to :booking, inverse_of: :notifications
  belongs_to :mail_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking

  scope :unsent, -> { where(sent_at: nil) }

  attribute :template_context
  validates :to, :locale, presence: true
  validate do
    next if booking.nil? || to.blank?
    next if booking.roles.keys.include?(to.to_sym)
    next if deliver_to.present?

    # next if Array.wrap(deliver_to).all? { Devise.email_regexp.match(_1) }

    errors.add(:to, :invalid)
  end

  def deliverable?
    valid? && organisation.notifications_enabled? && booking.notifications_enabled? && deliver_to.present?
  end

  def deliver
    deliverable? && update(sent_at: Time.zone.now, delivered_at: nil) && message_delivery.tap(&:deliver_later)
  end

  def autodeliver?
    mail_template&.autodeliver
  end

  def autodeliver!
    save!
    deliver if autodeliver?
  end

  def autodeliver
    deliver if save && autodeliver?
  end

  def autodeliver_with_redirect_proc
    return if autodeliver!

    closure_notification_id = to_param
    proc { edit_manage_notification_path(id: closure_notification_id) }
  end

  def attach(...)
    @attachment_manager ||= AttachmentManager.new(booking, target: attachments)
    @attachment_manager.attach_all(...)
  end

  def delivered?
    sent_at.present? && delivered_at.present?
  end

  def apply_template(mail_template, context: {})
    self.mail_template = mail_template
    self.template_context = context.merge(booking:, organisation:, notification: self)
    I18n.with_locale(locale) do
      interpolation_result = mail_template.becomes(RichTextTemplate).use(**template_context)
      self.subject = interpolation_result.title
      self.body = interpolation_result.body
    end
  end

  def footer
    I18n.with_locale(locale) do
      organisation.rich_text_templates.enabled.by_key(:notification_footer)&.interpolate(organisation:)&.body
    end
  end

  def text
    ActionView::Base.full_sanitizer.sanitize(html)
  end

  def html
    # rubocop:disable Rails/OutputSafety
    [body, footer].compact_blank.join.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def deliver_bcc
    [organisation&.bcc].compact
  end

  def deliver_to
    [resolve_to.try(:email).presence || resolve_to].flatten.compact
  end

  def locale
    @locale = resolve_to.try(:locale) || @locale.presence || booking&.locale || organisation&.locale
  end

  def resolve_to
    to.presence && (booking&.roles&.[](to.to_sym) || to)
  end

  def to=(value)
    super(case value
          when Tenant, Organisation, BookingAgent
            { Tenant => :tenant, Organisation => :administration, BookingAgent => :booking_agent }[value.class]
          when OperatorResponsibility
            value.responsibility
          when Operator
            value.email.presence
          else
            value.to_sym
          end)
  end

  protected

  def message_delivery
    @message_delivery ||= OrganisationMailer.booking_email(self)
  end
end
