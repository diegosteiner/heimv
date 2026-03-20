# frozen_string_literal: true

require 'yaml'

class RichTextTemplateService
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def save_defaults_from_organisation!
    build_defaults_from_organisation.each_pair do |locale, defaults_hash|
      locale_file = Rails.root.join("config/locales/rich_text_templates.#{locale}.yml")
      File.open(locale_file, 'wb') { it.write({ locale => defaults_hash }.to_yaml) }
    end
  end

  def build_defaults_from_organisation
    defaults = Hash.new { |hash, key| hash[key] = hash.dup.clear }
    organisation.rich_text_templates.find_each do |rich_text_template|
      build_default_from_organisation(defaults, rich_text_template)
    end
    defaults.freeze
  end

  def build_default_from_organisation(defaults, rich_text_template, locales:)
    key = rich_text_template.key
    I18n.available_locales.each do |locale|
      title = rich_text_template.title_i18n[locale.to_s]
      body = rich_text_template.body_i18n[locale.to_s]
      defaults[locale.to_s][key]['default_title'] = title if title
      defaults[locale.to_s][key]['default_body'] = body if body
    end
  end

  def missing_templates(include_optional: true)
    existing_keys = organisation.rich_text_templates.pluck(:key)
    RichTextTemplate.definitions.values.flatten.uniq.filter do |definition|
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
    template.load_defaults
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

  def self.defaults
    @defaults ||= Rails.root.glob('config/locales/rich_text_templates.*.yml').reduce({}) do |yaml, locale_file|
      yaml.merge(YAML.load_file(locale_file))
    end.with_indifferent_access.freeze
  end
end
