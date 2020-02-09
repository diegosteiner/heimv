module InOut
  class OrganisationInOut
    attr_reader :organisation

    def initialize(organisation)
      @organisation = organisation
    end

    def to_h
      organisation.attributes.slice(*relevant_attributes)
                  .merge(MarkdownTemplateInOut.new(organisation).to_h)
    end

    def from_h(hash, options = {})
      return false unless hash.is_a?(Hash)

      organisation.update(hash.slice(*relevant_attributes)) if options[:replace].present?
      MarkdownTemplateInOut.new(organisation).from_h(hash, options)
    end

    protected

    def relevant_attributes
      %w[name email address booking_ref_strategy_type booking_strategy_type currency
         esr_participant_nr iban invoice_ref_strategy_type message_footer]
    end
  end
end
