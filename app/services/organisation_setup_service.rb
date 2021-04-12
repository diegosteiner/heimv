# frozen_string_literal: true

class OrganisationSetupService
  attr_reader :organisation

  def self.create(**attributes)
    defaults = {
      booking_flow_type: BookingFlows::Default,
      invoice_ref_strategy_type: RefStrategies::ESR
    }
    organisation = Organisation.create!(defaults.merge(attributes))
    new(organisation)
  end

  def create_user!(email: organisation.email, password: SecureRandom.base64(32))
    user = User.create!(email: email, organisation: organisation, password: password, role: :manager)
    user.send_reset_password_instructions
  end

  def initialize(organisation)
    @organisation = organisation
  end

  def complete?
    organisation.valid? && missing_rich_text_templates.zero?
  end

  def create_missing_rich_text_templates!
    missing_rich_text_templates.map do |key|
      title = {}
      body = {}
      I18n.available_locales.map do |locale|
        scope = [:rich_text_templates, key]
        title[locale] = organisation.booking_flow.t(:default_title, scope: scope, locale: locale)
        body[locale] = organisation.booking_flow.t(:default_body, scope: scope, locale: locale)
      end
      organisation.rich_text_templates.create(key: key, title_i18n: title, body_i18n: body)
    end
  end

  def missing_rich_text_templates
    organisation.booking_flow.booking_states
    required_rich_text_templates = organisation.booking_flow.rich_text_templates.keys.map(&:to_s)
    required_rich_text_templates - organisation.rich_text_templates.where(home_id: nil).pluck(:key)
  end
end
