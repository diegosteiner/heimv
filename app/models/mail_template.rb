# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  autodeliver     :boolean          default(TRUE)
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
  def use(booking, to: nil, **context, &)
    return nil unless enabled

    booking&.notifications&.build(to:) do |notification|
      notification.apply_template(self, context: context.merge(booking:, organisation: booking.organisation))
      notification.destroy && return unless notification.deliverable?

      notification.tap(&) if block_given?
    end
  end

  class << self
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
