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

class Notification < ApplicationRecord
  extend RichTextTemplate::Definition

  use_template(:notification_footer, context: %i[booking])
  ArbitraryTo = Struct.new(:email, :locale)

  belongs_to :booking, inverse_of: :notifications
  belongs_to :mail_template, optional: true
  has_many_attached :attachments
  has_one :tenant, through: :booking
  has_one :organisation, through: :booking
  has_many :contracts, foreign_key: :sent_with_notification_id, inverse_of: :sent_with_notification, dependent: :nullify
  has_many :invoices, foreign_key: :sent_with_notification_id, inverse_of: :sent_with_notification, dependent: :nullify

  scope :unsent, -> { where(sent_at: nil) }
  before_save :deliver_to

  attribute :template_context
  validates :to, :locale, presence: true
  validate do
    next if deliver_to.present? && deliver_to.all? do
      EmailAddress.valid?(it, host_validation: :syntax)
    end

    errors.add(:to, :invalid)
  end

  def deliverable?
    valid? && organisation.notifications_enabled? && booking.notifications_enabled? && deliver_to.present?
  end

  def deliver
    sent_at = Time.zone.now
    return unless deliverable? && update(sent_at:, delivered_at: nil)

    contracts.each { it.update(sent_at:) }
    invoices.each { it.update(sent_at:) }
    message_delivery.tap(&:deliver_later)
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

    closure_notification_id = to_param # required assignment for closure to work
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
    organisation.rich_text_templates.enabled.by_key(:notification_footer)
                &.interpolate({ organisation: }, locale:)&.body
  end

  def text
    ActionView::Base.full_sanitizer.sanitize(html)
  end

  def html
    # rubocop:disable Rails/OutputSafety
    [body, footer].compact_blank.join.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def locale
    @locale = resolve_to.try(:locale) || @locale.presence || booking&.locale || organisation&.locale
  end

  def deliver_bcc
    [organisation&.bcc].compact
  end

  def deliver_to=(value)
    super(Array.wrap(value))
  end

  def deliver_to
    self[:deliver_to] = Array.wrap(super).compact_blank.presence || Array.wrap(resolve_to.try(:email)).compact_blank
  end

  def resolve_to
    return if to.blank?
    return booking&.roles&.[](to.to_sym) if Booking::ROLES.include?(to.to_sym)

    ArbitraryTo.new(to, booking&.locale)
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
            value&.to_s
          end)
  end

  def self.dedup(booking, to:, &)
    will_be_delivered_to = []
    Array.wrap(to).filter_map do |single_to|
      email = (booking.roles.key?(single_to) ? booking.roles[single_to] : single_to).try(:email)
      next if email.present? && will_be_delivered_to.include?(email)

      will_be_delivered_to << email
      yield single_to
    end
  end

  protected

  def message_delivery
    @message_delivery ||= OrganisationMailer.booking_email(self)
  end
end
