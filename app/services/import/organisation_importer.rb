# frozen_string_literal: true

module Import
  class OrganisationImporter < Base
    def relevant_attributes
      %w[name email address booking_ref_strategy_type booking_strategy_type currency location mail_from
         esr_beneficiary_account iban invoice_ref_strategy_type notification_footer notifications_enabled slug]
    end

    protected

    def to_h
      organisation.attributes.slice(*relevant_attributes)
                  .merge(rich_text_templates: RichTextTemplateImporter.new(organisation).export)
                  .merge(homes: HomeImporter.new(organisation).export)
                  .merge(purpose: BookingPurposeImporter.new(organisation).export)
    end

    def from_h(hash)
      organisation.update(hash.slice(*relevant_attributes)) if options[:replace].present?
      organisation if organisation.valid? && from_h_rich_text_templates(hash) && from_h_homes(hash)
    end

    def from_h_rich_text_templates(serialized)
      RichTextTemplateImporter.new(organisation, **options).import(serialized['rich_text_templates'])
    end

    def from_h_homes(serialized)
      HomeImporter.new(organisation, **options).import(serialized['homes'])
    end

    def from_h_purposes(serialized)
      BookingPurposeImporter.new(organisation, **options).import(serialized['purposes'])
    end
  end
end
