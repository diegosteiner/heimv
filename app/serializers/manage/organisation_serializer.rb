# frozen_string_literal: true

module Manage
  class OrganisationSerializer < Public::OrganisationSerializer
    association :booking_categories, blueprint: BookingCategorySerializer
    association :rich_text_templates, blueprint: RichTextTemplateSerializer
    association :homes, blueprint: HomeSerializer
    association :tenants, blueprint: TenantSerializer
    association :designated_documents, blueprint: DesignatedDocumentSerializer
    association :tarifs, blueprint: TarifSerializer

    fields :qr_iban, :esr_beneficiary_account, :iban, :mail_from
    field :settings do |organisation|
      organisation.settings.to_h
    end

    view :export do
      include_view :default

      association :booking_categories, blueprint: BookingCategorySerializer, view: :export
    end
  end
end
