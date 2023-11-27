# frozen_string_literal: true

require 'yaml'

class RichTextTemplateService
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def load_defaults_from_organisation!
    load_defaults_from_organisation.each_pair do |locale_file, yaml|
      File.open(locale_file, 'wb') { _1.write yaml.to_yaml }
    end
  end

  def load_defaults_from_organisation
    Dir[Rails.root.join('config/locales/*.yml')].to_h do |locale_file|
      yaml = YAML.load_file(locale_file)
      locale = yaml.keys.first
      set_rich_text_template_defaults(yaml, locale)
      [locale_file, yaml]
    end
  end

  def set_rich_text_template_defaults(yaml, locale)
    organisation.rich_text_templates.each do |rich_text_template|
      key = rich_text_template.key
      title = rich_text_template.title_i18n[locale]
      body = rich_text_template.body_i18n[locale]

      yaml[locale]['rich_text_templates'][key]['default_title'] = title if title
      yaml[locale]['rich_text_templates'][key]['default_body'] = body if body
    end
  end

  def missing_templates(include_optional: true)
    existing_keys = organisation.rich_text_templates.pluck(:key)
    RichTextTemplate.definitions.values.flatten.uniq.filter do |definition|
      existing_keys.exclude?(definition[:key].to_s) && (!definition.fetch(:optional, false) || include_optional)
    end
  end

  def create_missing!(include_optional: true)
    missing_templates(include_optional:).map do |definition|
      build_from_defintion(definition, **(include_optional ? { enabled: true } : {})).tap(&:save!)
    end
  end

  def build_from_defintion(definition, **attributes)
    title = {}
    body = {}
    I18n.available_locales.map do |locale|
      title[locale] = defaults_for_locale(:default_title, definition[:key], locale)
      body[locale]  = defaults_for_locale(:default_body, definition[:key], locale)
    end
    RichTextTemplate.new({ key: definition[:key], type: definition[:type].to_s, organisation:, title_i18n: title,
                           body_i18n: body, enabled: !definition.fetch(:optional, false) }.merge(attributes))
  end

  def replace_in_template!(search, replace, scope: @organisation.rich_text_templates)
    scope.each do |rich_text_template|
      rich_text_template.body_i18n.transform_values! { _1.gsub(search, replace) }
      rich_text_template.title_i18n.transform_values! { _1.gsub(search, replace) }
      rich_text_template.save
    end
  end

  def find_in_template(search, scope: @organisation.rich_text_templates)
    scope.filter do |rich_text_template|
      rich_text_template.body_i18n.values.any? { _1.scan(search).present? } ||
        rich_text_template.title_i18n.values.any? { _1.scan(search).present? }
    end
  end

  private

  def defaults_for_locale(kind, key, locale)
    I18n.t(kind, scope: [:rich_text_templates, key], locale:, default: nil)
  end
end
