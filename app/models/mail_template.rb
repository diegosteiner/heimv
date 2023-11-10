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
  def deliver(*)
    use(*).map { [_2, _2&.deliver] }
  end

  def use(booking, to: nil, attach: [], **context, &)
    booking.notifications.build(to: resolve_to(to, booking)).tap do |notification|
      notification.apply_template(self, context: context.merge(booking:, organisation: booking.organisation))
      notification.attach(*Array.wrap(attach))
      notification.tap(&) if block_given?
    end
  end

  def use_default(booking, tos: nil, attach: nil, **, &)
    Array.wrap(tos || definition[:to]).index_with do |to|
      use(booking, to:, attach: attach.presence || definition[:attach], **, &)
    end
  end

  def resolve_to(to, booking)
    booking&.instance_eval do
      return tenant if to == :tenant
      return agent_booking&.booking_agent if to == :booking_agent
      return responsibilities[to] if responsibilities[to].present?
      return organisation if to == :administation
    end

    to
  end

  def self.use(key, booking, **, &)
    booking.organisation.rich_text_templates.where(type: to_s).by_key(key)&.use(booking, **, &)
  end
end
