# frozen_string_literal: true

module Import
  module Hash
    class OrganisationImporter < Base
      use_attributes(*%w[slug address booking_flow_type settings accounting_settings booking_state_settings
                         booking_ref_template country_code currency email esr_beneficiary_account iban
                         invoice_payment_ref_template invoice_ref_template location deadline_settings
                         mail_from name nickname_label_i18n notifications_enabled tenant_ref_template])

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

      actor do |organisation, hash|
        vat_categories = hash['vat_categories']
        next unless vat_categories.is_a?(Array)

        vat_categories.map { |vat_category| organisation.vat_categories.build(vat_category) }
      end

      # TODO: booking_agents
    end
  end
end
