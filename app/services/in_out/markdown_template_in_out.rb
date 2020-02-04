module InOut
  class MarkdownTemplateInOut
    attr_reader :organisation

    def initialize(organisation)
      @organisation = organisation
    end

    def to_a
      organisation.markdown_templates.find_each.map do |markdown_template|
        markdown_template.attributes.slice(*relevant_attributes)
      end
    end

    def from_a(markdown_templates_attributes, replace: false)
      MarkdownTemplate.transaction do
        markdown_templates_attributes.map do |attributes|
          markdown_template = organisation.markdown_templates.find_or_initialize_by(
            key: attributes[:key],
            locale: attributes[:locale]
          )
          markdown_template.update(attributes) if markdown_template.new_record? || replace
        end
      end
    end

    def to_h
      { 'markdown_templates' => to_a }
    end

    def from_h(hash, options = {})
      from_a(hash.fetch(:markdown_templates, []), replace: options[:replace].present?)
    end

    protected

    def relevant_attributes
      %w[key title body locale]
    end
  end
end
