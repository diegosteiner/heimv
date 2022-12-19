# frozen_string_literal: true

require 'yaml'

class RichTextTemplateService
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def load_defaults_from_organisation!
    Dir[Rails.root.join('config/locales/*.yml')].each do |locale_file|
      yaml = YAML.load_file(locale_file)
      locale = yaml.keys.first
      set_rich_text_template_defaults(yaml, locale)

      File.open(locale_file, 'wb') { _1.write yaml.to_yaml }
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

  def missing_requirements(include_optional: true)
    existing_keys = organisation.rich_text_templates.pluck(:key)
    RichTextTemplate.required_templates.values.flatten.uniq.filter do |requirement|
      existing_keys.exclude?(requirement.key.to_s) && (!requirement.optional || include_optional)
    end
  end

  def create_missing!(include_optional: true)
    title = {}
    body = {}
    missing_requirements.map do |requirement|
      I18n.available_locales.map do |locale|
        title[locale] = defaults_for_locale(:default_title, requirement.key, locale)
        body[locale]  = defaults_for_locale(:default_body, requirement.key, locale)
      end
      organisation.rich_text_templates.create(key: requirement.key, title_i18n: title, body_i18n: body,
                                              enabled: !requirement.optional || include_optional)
    end
  end

  def replace_in_template!(search, replace)
    @organisation.rich_text_templates.each do |rich_text_template|
      rich_text_template.body_i18n.transform_values! { _1.gsub(search, replace) }
      rich_text_template.title_i18n.transform_values! { _1.gsub(search, replace) }
      rich_text_template.save
    end
  end

  def find_in_template(search)
    @organisation.rich_text_templates.filter do |rich_text_template|
      rich_text_template.body_i18n.values.any? { _1.scan(search).present? } ||
        rich_text_template.title_i18n.values.any? { _1.scan(search).present? }
    end
  end

  private

  def defaults_for_locale(kind, key, locale)
    I18n.t(kind, scope: [:rich_text_templates, key], locale: locale, default: nil)
  end
end
