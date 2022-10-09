# frozen_string_literal: true

module Import
  module Hash
    class OrganisationImporter < Base
      use_attributes(*%w[name email address booking_flow_type currency location mail_from
                         esr_beneficiary_account iban invoice_ref_strategy_type
                         notifications_enabled slug settings])

      def initialize_record(_hash)
        Organisation.new
      end

      actor do |organisation, hash|
        next unless hash['rich_text_templates'].respond_to?(:each)

        importer = RichTextTemplateImporter.new(organisation, **options)
        hash['rich_text_templates'].each { |template| organisation.rich_text_templates << importer.import(template) }
      end

      actor do |organisation, hash|
        next unless hash['homes'].respond_to?(:each)

        importer = HomeImporter.new(organisation, **options)
        hash['homes'].each { |home| organisation.homes << importer.import(home) }
      end

      actor do |organisation, hash|
        next unless hash['booking_categories'].respond_to?(:each)

        importer = BookingCategoryImporter.new(organisation, **options)
        hash['booking_categories'].each { |category| organisation.booking_categories << importer.import(category) }
      end

      actor do |organisation, hash|
        next unless hash['tarifs'].respond_to?(:each)

        importer = TarifImporter.new(organisation, **options)
        hash['tarifs'].each { |tarif| organisation.tarifs << importer.import(tarif) }
      end
    end
  end
end
