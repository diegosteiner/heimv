# frozen_string_literal: true

class RichTextTemplateService
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def load_defaults_from_organisation(organisation)
    require 'yaml'
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
