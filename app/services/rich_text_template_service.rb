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
    Rails.root.glob('config/locales/*.yml').to_h do |locale_file|
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
    RichTextTemplate.definitions.values.flatten.filter do |definition|
      existing_keys.exclude?(definition[:key].to_s) && (!definition.fetch(:optional, false) || include_optional)
    end
  end

  def create_missing!(enable_optional: true)
    missing_templates(include_optional: true).map do |definition|
      enabled = !definition.fetch(:optional, false) || enable_optional
      build_from_defintion(definition, enabled:).tap(&:save!)
    end
  end

  def build_from_defintion(definition, enabled: nil)
    enabled ||= !definition.fetch(:optional, false)
    template = RichTextTemplate.new({ key: definition[:key], type: definition[:type].to_s, organisation:,
                                      autodeliver: definition.fetch(:autodeliver, true), enabled: })
    template.load_locale_defaults
    template
  end

  def replace_in_templates!(search, replace, scope: @organisation.rich_text_templates)
    @organisation.rich_text_templates.merge(scope).map do |rich_text_template|
      rich_text_template.gsub!(search, replace)
      rich_text_template.save!
      rich_text_template
    end
  end

  def find_in_templates(search, scope: @organisation.rich_text_templates)
    @organisation.rich_text_templates.merge(scope).to_a.filter { it.include?(search) }
  end
end
