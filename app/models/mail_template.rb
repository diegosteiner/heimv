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

class MailTemplate < RichTextTemplate
  has_many :mail_template_designated_documents, dependent: :destroy
  has_many :designated_documents, through: :mail_template_designated_documents
  has_many :notifications, inverse_of: :mail_template, dependent: :nullify

  def use(booking, to: nil, attach: nil, context: {}, **args, &callback)
    return nil unless enabled

    booking&.notifications&.build(to:, **args) do |notification|
      notification.apply_template(self, context: context.merge(booking:, organisation: booking.organisation))
      notification.destroy && return unless notification.deliverable?

      notification.attach(designated_documents.for_booking(booking))
      notification.tap(&callback) if callback.present?
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
