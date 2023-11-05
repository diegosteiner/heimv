# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  body_i18n       :jsonb
#  enabled         :boolean          default(TRUE)
#  key             :string
#  title_i18n      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_rich_text_templates_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id          (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class MailTemplate < RichTextTemplate
  RECIPIENT_FLAGS = [:tenant] + OperatorResponsibility::RESPONSIBILITIES.keys
  ATTACHABLE_BOOKING_DOCUMENTS = {
    unsent_deposits: ->(booking) { booking.invoices.deposit.unsent },
    unsent_invoices: ->(booking) { booking.invoices.invoice.unsent },
    unsent_late_notices: ->(booking) { booking.invoices.late_notice.unsent },
    unsent_offers: ->(booking) { booking.invoices.offers.unsent },
    unsent_contract: ->(booking) { booking.contract.unsent }
  }.freeze

  # has_and_belongs_to_many :designated_documents

  flag :attach_booking_documents, ATTACHABLE_BOOKING_DOCUMENTS.keys
  flag :to, RECIPIENT_FLAGS
  flag :cc, RECIPIENT_FLAGS
  flag :bcc, RECIPIENT_FLAGS

  private

  def build_notification(booking)
    I18n.with_locale(booking.locale) do
      booking.build_notification.tap do |notification|
        interpolation_result = interpolate(booking)
        notification.subject = interpolation_result.title
        notification.body = interpolation_result.body
        notification.attach(*prepare_attachments)
      end
    end
  end

  def prepare_attachments
    [
      designated_documents.for_booking(booking),
      ATTACHABLE_BOOKING_DOCUMENTS.slice(attach_booking_documents).map(&:pdf)
    ].flatten.compact
  end
end
