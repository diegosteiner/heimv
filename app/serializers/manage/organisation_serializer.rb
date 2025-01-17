# frozen_string_literal: true

module Manage
  class OrganisationSerializer < Public::OrganisationSerializer
    association :booking_categories, blueprint: BookingCategorySerializer
    association :rich_text_templates, blueprint: RichTextTemplateSerializer
    association :homes, blueprint: HomeSerializer
    # association :tenants, blueprint: TenantSerializer
    # association :designated_documents, blueprint: DesignatedDocumentSerializer
    association :tarifs, blueprint: TarifSerializer
    association :booking_questions, blueprint: Public::BookingQuestionSerializer
    association :vat_categories, blueprint: Public::VatCategorySerializer

    fields :esr_beneficiary_account, :iban, :mail_from, :booking_ref_template, :tenant_ref_template,
           :invoice_ref_template, :booking_flow_type, :invoice_payment_ref_template,
           :notifications_enabled, :location, :nickname_label_i18n

    field :designated_documents do |organisation|
      organisation.designated_documents.pluck(:designation).map do |designation|
        next if designation.blank?

        [designation,
         url.public_designated_document_url(org: organisation, designation:, locale: I18n.locale)]
      end.compact_blank.to_h
    end

    field :settings do |organisation|
      organisation.settings.attributes
    end

    field :booking_state_settings do |organisation|
      organisation.booking_state_settings.attributes
    end

    field :deadline_settings do |organisation|
      organisation.deadline_settings.attributes
    end

    field :accounting_settings do |organisation|
      organisation.accounting_settings.attributes
    end

    view :export do
      include_view :default

      association :booking_categories, blueprint: BookingCategorySerializer, view: :export
    end
  end
end
