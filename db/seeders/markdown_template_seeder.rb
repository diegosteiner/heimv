require_relative './base_seeder'

module Seeders
  class MarkdownTemplateSeeder < BaseSeeder
    def seed!
      markdown_templates = YAML::load_file(Rails.root.join('db', 'seeds', 'markdown_templates.yml'))

      {
        markdown_templates: markdown_templates.map do |_key, template_data|
          MarkdownTemplate.create!(template_data)
        end
      }
    end
  end
end
