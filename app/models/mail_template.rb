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
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_rich_text_templates_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id          (organisation_id)
#  index_rich_text_templates_on_type                     (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class MailTemplate < RichTextTemplate
  ATTACHABLE_BOOKING_DOCUMENTS = {
    unsent_deposits: ->(booking) { booking.invoices.deposit.unsent.map(&:pdf) },
    unsent_invoices: ->(booking) { booking.invoices.invoice.unsent.map(&:pdf) },
    unsent_late_notices: ->(booking) { booking.invoices.late_notice.unsent.map(&:pdf) },
    unsent_offers: ->(booking) { booking.invoices.offers.unsent.map(&:pdf) },
    unsent_contract: ->(booking) { booking.contract.unsent.map(&:pdf) },
    designated_documents: ->(booking) { designated_documents.for_booking(booking) }
  }.freeze

  def use(booking, to:, attach: [], **context)
    to = resolve_to(to)
    locale = to&.locale || booking.locale
    context = context.reverse_merge({ booking: })
    I18n.with_locale(locale) do
      interpolated = super(**context)
      booking.build_notification(subject: interpolated.title, body: interpolated.body, locale:).tap do |notification|
        notification.attach(*prepare_attachments(booking, attach))
      end
    end
  end

  private

  def prepare_attachments(booking, attach = [])
    Array.wrap(attach).map { ATTACHABLE_BOOKING_DOCUMENTS[_1]&.call(booking) }.flatten.compact
  end
end
