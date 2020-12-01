# frozen_string_literal: true

class OrganisationSetupService
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def complete?
    organisation.valid? && missing_markdown_templates.zero?
  end

  def create_missing_markdown_templates!
    missing_markdown_templates.each do |key|
      title = {}
      body = {}
      I18n.available_locales.map do |locale|
        scope = [:markdown_templates, key]
        title[locale] = organisation.booking_strategy.t(:default_title, scope: scope, locale: locale)
        body[locale] = organisation.booking_strategy.t(:default_body, scope: scope, locale: locale)
      end
      organisation.markdown_templates.create(key: key, title_i18n: title, body_i18n: body)
    end
  end

  def missing_markdown_templates
    required_markdown_templates = organisation.booking_strategy.markdown_templates.keys.map(&:to_s)
    required_markdown_templates - organisation.markdown_templates.where(home_id: nil).pluck(:key)
  end
end
