module Import
  class MarkdownTemplateImporter < Base
    def relevant_attributes
      %w[key title body locale]
    end

    protected

    def _export
      organisation.markdown_templates.find_each.map do |markdown_template|
        [markdown_template.id, markdown_template.attributes.slice(*relevant_attributes)]
      end.to_h
    end

    def _import(serialized)
      serialized.map do |_id, attributes|
        template = organisation.markdown_templates.find_or_initialize_by(attributes.slice('key', 'locale'))
        template.update(attributes.slice(*relevant_attributes)) if template.new_record? || options[:replace]
        template if template.valid?
      end
    end
  end
end
