# frozen_string_literal: true

module Manage
  class OrganisationSerializer < ApplicationSerializer
    view :export do
      fields(*Import::Hash::OrganisationImporter.used_attributes.map(&:to_sym))
      association :booking_purposes, blueprint: Public::BookingPurposeSerializer
      association :rich_text_templates, blueprint: RichTextTemplateSerializer
      association :homes, blueprint: HomeSerializer, view: :export
      association :tenants, blueprint: TenantSerializer
    end
  end
end
