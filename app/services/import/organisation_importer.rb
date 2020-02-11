module Import
  class OrganisationImporter
    attr_reader :organisation

    def initialize(organisation, options = { replace: false })
      @organisation = organisation
      @options = options
    end

    def to_h
      organisation.attributes.slice(*relevant_attributes)
                  .merge(markdown_templates: MarkdownTemplateImporter.new(organisation).to_h)
    end

    def from_h(hash, options = {})
      return false unless hash.is_a?(Hash)

      organisation.update(hash.slice(*relevant_attributes)) if options[:replace].present?
      [
        organisation,
        MarkdownTemplateImporter.new(organisation, @options).from_h(hash[:markdown_templates])
      ]
    end

    protected

    def relevant_attributes
      %w[name email address booking_ref_strategy_type booking_strategy_type currency
         esr_participant_nr iban invoice_ref_strategy_type message_footer]
    end
  end
end
