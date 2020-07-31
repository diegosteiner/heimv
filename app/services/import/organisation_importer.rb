module Import
  class OrganisationImporter < Base
    def relevant_attributes
      %w[name email address booking_ref_strategy_type booking_strategy_type currency location domain
         esr_participant_nr iban invoice_ref_strategy_type message_footer messages_enabled]
    end

    protected

    def _export
      organisation.attributes.slice(*relevant_attributes)
                  .merge(markdown_templates: MarkdownTemplateImporter.new(organisation).export)
                  .merge(homes: HomeImporter.new(organisation).export)
    end

    def _import(hash)
      organisation.update(hash.slice(*relevant_attributes)) if options[:replace].present?
      organisation if organisation.valid? && _import_markdown_templates(hash) && _import_homes(hash)
    end

    def _import_markdown_templates(serialized)
      MarkdownTemplateImporter.new(organisation, options).import(serialized['markdown_templates'])
    end

    def _import_homes(serialized)
      HomeImporter.new(organisation, options).import(serialized['homes'])
    end
  end
end
