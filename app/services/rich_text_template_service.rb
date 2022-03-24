# frozen_string_literal: true

require 'yaml'

class RichTextTemplateService
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  # rubocop:disable Metrics/AbcSize
  def load_defaults_from_organisation!
    Dir[Rails.root.join('config/locales/*.yml')].each do |locale_file|
      yaml = YAML.load_file(locale_file)
      locale = yaml.keys.first

      organisation.rich_text_templates.each do |rich_text_template|
        key = rich_text_template.key
        yaml[locale]['rich_text_templates'][key]['default_title'] = rich_text_template.title_i18n[locale]
        yaml[locale]['rich_text_templates'][key]['default_body'] = rich_text_template.body_i18n[locale]
      end

      File.open(locale_file, 'wb') { _1.write yaml.to_yaml }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def missing_requirements(include_optional: true)
    existing_keys = organisation.rich_text_templates.pluck(:key)
    RichTextTemplate.required_templates.values.flatten.filter do |requirement|
      existing_keys.exclude?(requirement.key.to_s) && (!requirement.optional || include_optional)
    end
  end

  def create_missing!(include_optional: true)
    title = {}
    body = {}
    missing_requirements(include_optional: include_optional).map do |requirement|
      scope = [:rich_text_templates, requirement.key]
      I18n.available_locales.map do |locale|
        title[locale] = I18n.t(:default_title, scope: scope, locale: locale)
        body[locale]  = I18n.t(:default_body, scope: scope, locale: locale)
      end
      RichTextTemplate.create(key: requirement.key, title_i18n: title, body_i18n: body, organisation: organisation)
    end
  end
end
