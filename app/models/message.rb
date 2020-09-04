# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("manager"), not null
#  body                 :text
#  cc                   :string           default([]), is an Array
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
#  index_messages_on_booking_id            (booking_id)
#  index_messages_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

class Message < ApplicationRecord
  class NotDeliverable < StandardError; end

  belongs_to :booking, inverse_of: :messages
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

  before_validation :link_markdown_template, :apply_markdown_template
  before_validation do
    self.to = to.presence || resolve_addressed_to
  end

  def subject_with_ref
    # TODO: Replace with liquid template
    [subject, "[#{booking.ref}]"].compact.join(' ')
  end

  def markdown
    @markdown ||= Markdown.new(body)
  end

  def markdown=(value)
    self.body = value.body
    @markdown = value
  end

  def deliverable?
    valid? && organisation.messages_enabled? && (booking.messages_enabled? || addressed_to_manager?)
  end

  def deliver
    deliver!
  rescue NotDeliverable
    false
  end

  def deliver!
    raise NotDeliverable, from_template unless deliverable?

    deliver_mail! && update(sent_at: Time.zone.now)
  end

  def attachments_for_mail
    Hash[attachments.map { |attachment| [attachment.filename.to_s, attachment.blob.download] }]
  end

  def link_markdown_template
    return if from_template.blank? || organisation.blank? || booking.blank?

    self.markdown_template = organisation.markdown_templates.by_key(from_template, locale: booking.locale)
  end

  def apply_markdown_template
    return false if markdown_template.blank?

    self.subject = markdown_template.title
    self.markdown = markdown_template.interpolate('booking' => booking)
  end

  protected

  def resolve_addressed_to
    return [booking.email].compact if addressed_to_tenant?
    return [booking.booking_agent&.email].compact if addressed_to_booking_agent?

    [booking.organisation.email]
  end

  def deliver_mail!
    organisation.mailer.mail(to: to, subject: subject_with_ref, cc: cc, bcc: bcc,
                             body: markdown.to_text, html_body: markdown.to_html,
                             attachments: attachments_for_mail)
  end
end
