# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id               :bigint           not null, primary key
#  addressed_to     :integer          default("manager"), not null
#  bcc              :string
#  body             :text
#  cc               :string           default([]), is an Array
#  locale           :string           default(NULL), not null
#  sent_at          :datetime
#  subject          :string
#  to               :string           default([]), is an Array
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

  locale_enum

  validates :to, :locale, presence: true
  before_validation
  attribute :template_context

  def deliverable?
    valid? && organisation.notifications_enabled? && booking.notifications_enabled?
  end

  def deliver
    deliverable? && save && message_delivery.tap(&:deliver_later)
  end

  def delivered?
    sent_at.present?
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

  def apply_template(mail_template, locale: nil, context: {})
    locale ||= booking&.locale
    self.locale = locale
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
    [super, organisation&.bcc].compact
  end

  def to=(value)
    self.locale = value.locale if value.respond_to?(:locale)
    super(value)
  end

  def self.resolve_to(to, booking)
    booking&.instance_eval do
      return tenant if to == :tenant
      return agent_booking&.booking_agent if to == :booking_agent
      return responsibilities[to] if responsibilities[to].present?
      return organisation if to == :administration
    end
    # raise StandardError, "#{to} is not a valid recipient" unless responsibilities.key?(to)
  end

  def deliver_to
    to = self.class.resolve_to(self.to, booking)
    to = to&.email if to.respond_to?(:email)
    super([to.presence].flatten.compact)
  end

  protected

  def message_delivery
    @message_delivery ||= OrganisationMailer.booking_email(self)
  end
end
