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
    unsent_contract: ->(booking) { booking.contract.unsent },
    last_info_documents: ->(booking) { DesignatedDocument.for_booking(booking).where(send_with_last_infos: true) },
    contract_documents: ->(booking) { DesignatedDocument.for_booking(booking).where(send_with_contract: true) }
  }.freeze

  belongs_to :booking, inverse_of: :notifications
  belongs_to :mail_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking

  locale_enum
  enum addressed_to: { manager: 0, tenant: 1, booking_agent: 2 }, _prefix: true

  validates :to, :locale, presence: true
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
    attachables.map do |attachable|
      next attachable.attach_to(self) if attachable.respond_to?(:attach_to)
      next attach(attachable.blob) if attachable.try?(:blob).present?
      next attach(*attachable_booking_documents(key)) if attachable_booking_documents(key)

      attachments.attach(attachable)
    end
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

  def bcc
    [super, organisation&.bcc].compact
  end

  def to=(value)
    self.locale = value.locale if value.respond_to?(:locale)
    # self.addressed_to = value  # TODO: change db field

    value = value.email if value.respond_to?(:email)
    super([value.presence].flatten.compact)
  end

  protected

  def message_delivery
    @message_delivery ||= OrganisationMailer.booking_email(self)
  end
end
