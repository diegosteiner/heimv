# frozen_string_literal: true

module Import
  class RichTextTemplateImporter < Base
    def relevant_attributes
      %w[key title_i18n body_i18n home_id]
    end

    protected

    def to_h
      organisation.rich_text_templates.find_each.map do |rich_text_template|
        [rich_text_template.id, rich_text_template.attributes.slice(*relevant_attributes)]
      end.to_h
    end

    def from_h(serialized)
      serialized.map do |_id, attributes|
        identifying_attributes = attributes.slice('key', 'home_id')
        template = organisation.rich_text_templates.find_or_initialize_by(identifying_attributes)
        template.update(attributes.slice(*relevant_attributes)) if template.new_record? || options[:replace]
        template if template.valid?
      end
    end
  end
end
