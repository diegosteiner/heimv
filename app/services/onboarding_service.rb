# frozen_string_literal: true

class OnboardingService
  attr_reader :organisation

  def self.create(**attributes)
    defaults = {
      booking_flow_type: BookingFlows::Default,
      invoice_ref_strategy_type: RefStrategies::ESR
    }
    organisation = Organisation.create!(defaults.merge(attributes))
    new(organisation)
  end

  def add_or_invite_user!(email: organisation.email, password: SecureRandom.base64(32), role: :manager)
    User.find_or_initialize_by(email: email) do |new_user|
      new_user.update!(password: password) && new_user.send_reset_password_instructions
    end.organisation_users.create(organisation: organisation, role: role)
  end

  def initialize(organisation)
    @organisation = organisation
  end

  def complete?
    organisation.valid? && missing_rich_text_templates.zero?
  end

  def create_home!(**attributes)
    organisation.homes.create!(attributes)
  end

  def missing_rich_text_templates(include_optional: true)
    RichTextTemplate.missing_requirements(organisation, include_optional: include_optional)
  end

  def create_missing_rich_text_templates!(include_optional: true)
    title = {}
    body = {}
    missing_rich_text_templates(include_optional: include_optional).map do |requirement|
      scope = [:rich_text_templates, requirement.key]
      I18n.available_locales.map do |locale|
        title[locale] = I18n.t(:default_title, scope: scope, locale: locale)
        body[locale]  = I18n.t(:default_body, scope: scope, locale: locale)
      end
      RichTextTemplate.create(key: requirement.key, title_i18n: title, body_i18n: body, organisation: organisation)
    end
  end
end
