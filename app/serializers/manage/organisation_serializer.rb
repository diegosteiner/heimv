# frozen_string_literal: true

module Manage
  class OrganisationSerializer < Public::OrganisationSerializer
    association :booking_categories, blueprint: BookingCategorySerializer, view: :export
    association :rich_text_templates, blueprint: RichTextTemplateSerializer
    association :homes, blueprint: HomeSerializer, view: :export
    association :tenants, blueprint: TenantSerializer
    association :designated_documents, blueprint: DesignatedDocumentSerializer

    fields :iban, :mail_from
    field :settings do |organisation|
      organisation.settings.to_h
    end

    view :export do
      include_view :default
    end
  end
end
