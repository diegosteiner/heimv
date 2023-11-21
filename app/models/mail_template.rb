# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id                           :bigint           not null, primary key
#  attachable_booking_documents :integer
#  body_i18n                    :jsonb
#  enabled                      :boolean          default(TRUE)
#  key                          :string
#  title_i18n                   :jsonb
#  type                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  organisation_id              :bigint           not null
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
  flag :attachable_booking_documents, Notification::ATTACHABLE_BOOKING_DOCUMENTS.keys

  def use(booking, to: nil, **context, &)
    return unless enabled

    Notification.build(booking:, to: resolve_to(to, booking)).tap do |notification|
      notification.apply_template(self, context: context.merge(booking:, organisation: booking.organisation))
      notification.attach(*Array.wrap(attachable_booking_documents))
      notification.tap(&) if block_given?
    end
  end

  def resolve_to(*)
    self.class.resolve_to(*)
  end

  def reset_attachable_booking_documents!
    update!(attachable_booking_documents: definition[:attach])
  end

  class << self
    def resolve_to(to, booking)
      booking&.instance_eval do
        return tenant if to == :tenant
        return agent_booking&.booking_agent if to == :booking_agent
        return responsibilities[to] if responsibilities[to].present?
        return organisation if to == :administration
      end
      # raise StandardError, "#{to} is not a valid recipient" unless responsibilities.key?(to)
    end

    def use(key, booking, **, &)
      use!(key, booking, **, &)
    rescue RichTextTemplate::NoTemplate
      nil
    end

    def use!(key, booking, **, &)
      raise RichTextTemplate::InvalidDefinition unless definitions.key?(key)

      booking.organisation.rich_text_templates.where(type: to_s).by_key!(key).use(booking, **, &)
    end
  end
end
