# frozen_string_literal: true

module Import
  class MarkdownTemplateImporter < Base
    def relevant_attributes
      %w[key title_i18n body_i18n home_id]
    end

    protected

    def to_h
      organisation.markdown_templates.find_each.map do |markdown_template|
        [markdown_template.id, markdown_template.attributes.slice(*relevant_attributes)]
      end.to_h
    end

    def from_h(serialized)
      serialized.map do |_id, attributes|
        identifying_attributes = attributes.slice('key', 'home_id')
        template = organisation.markdown_templates.find_or_initialize_by(identifying_attributes)
        template.update(attributes.slice(*relevant_attributes)) if template.new_record? || options[:replace]
        template if template.valid?
      end
    end
  end
end
