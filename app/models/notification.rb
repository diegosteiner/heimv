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
  ATTACHABLE_BOOKING_DOCUMENTS = {
    unsent_deposits: ->(booking) { booking.invoices.deposit.unsent },
    unsent_invoices: ->(booking) { booking.invoices.invoice.unsent },
    unsent_late_notices: ->(booking) { booking.invoices.late_notice.unsent },
    unsent_offers: ->(booking) { booking.invoices.offers.unsent },
    contract: ->(booking) { booking.contract },
    last_info_documents: ->(booking) { DesignatedDocument.for_booking(booking).where(send_with_last_infos: true) },
    contract_documents: ->(booking) { DesignatedDocument.for_booking(booking).where(send_with_contract: true) }
  }.freeze

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

    # next if Devise.email_regexp =~ to.to_s

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

  def autodeliver
    return save && false unless autodeliver?

    deliver
  end

  def delivered?
    sent_at.present? && delivered_at.present?
  end

  def attach(*attachables)
    attachables.flatten.compact.map do |attachable|
      next attachable.attach_to(self) if attachable.respond_to?(:attach_to)
      next attach(attachable.blob) if attachable.try(:blob).present?

      booking_documents = attachable_booking_documents(attachable)
      next attach(*booking_documents) unless booking_documents.nil?

      attachments.attach(attachable)
    end
  end

  def attachable_booking_documents(key)
    return if booking.blank? || !ATTACHABLE_BOOKING_DOCUMENTS.key?(key)

    ATTACHABLE_BOOKING_DOCUMENTS[key].call(booking) || []
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
    organisation.rich_text_templates.enabled.by_key(:notification_footer)&.interpolate(organisation:)&.body
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
    [resolve_to.try(:email).presence || resolve_to.to_s.presence].flatten.compact
  end

  def locale
    @locale = resolve_to.try(:locale) || @locale.presence || booking&.locale
  end

  def resolve_to
    to.presence && booking&.roles&.[](to.to_sym)
  end

  def to=(value)
    super case value
          when Tenant, Organisation, BookingAgent
            { Tenant => :tenant, Organisation => :administration, BookingAgent => :booking_agent }[value.class]
          when OperatorResponsibility
            value.responsibility
          else
            value.to_sym
          end
  end

  protected

  def message_delivery
    @message_delivery ||= OrganisationMailer.booking_email(self)
  end
end
