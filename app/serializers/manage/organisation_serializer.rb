# frozen_string_literal: true

module Manage
  class OrganisationSerializer < ApplicationSerializer
    view :export do
      fields(*Import::Hash::OrganisationImporter.used_attributes.map(&:to_sym))
      field :settings do |organisation|
        organisation.settings.to_h
      end
      association :booking_categories, blueprint: BookingCategorySerializer, view: :export
      association :rich_text_templates, blueprint: RichTextTemplateSerializer
      association :homes, blueprint: HomeSerializer, view: :export
      association :tenants, blueprint: TenantSerializer
      association :designated_documents, blueprint: DesignatedDocumentSerializer
    end
  end
end
