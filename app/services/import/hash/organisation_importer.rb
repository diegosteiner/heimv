# frozen_string_literal: true

module Import
  module Hash
    class OrganisationImporter < Base
      use_attributes(*%w[name email address booking_flow_type currency location mail_from
                         esr_beneficiary_account iban invoice_ref_strategy_type
                         notifications_enabled slug])

      def initialize_record(_hash)
        Organisation.new
      end

      actor do |organisation, hash|
        next unless hash['rich_text_templates'].respond_to?(:each)

        importer = RichTextTemplateImporter.new(organisation, **options)

        hash['rich_text_templates'].each do
          organisation.rich_text_templates << importer.import(_1)
        end
      end

      actor do |organisation, hash|
        next unless hash['homes'].respond_to?(:each)

        importer = HomeImporter.new(organisation, **options)

        hash['homes'].each do
          organisation.homes << importer.import(_1)
        end
      end

      actor do |organisation, hash|
        next unless hash['booking_purposes'].respond_to?(:each)

        importer = BookingPurposeImporter.new(organisation, **options)

        hash['booking_purposes'].each do
          organisation.booking_purposes << importer.import(_1)
        end
      end
    end
  end
end
