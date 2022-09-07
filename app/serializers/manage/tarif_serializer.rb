# frozen_string_literal: true

module Manage
  class TarifSerializer < ApplicationSerializer
    fields :label, :invoice_type, :pin, :prefill_usage_method, :price_per_unit,
           :tarif_group, :tenant_visible, :type, :unit

    view :export do
      fields(*Import::Hash::TarifImporter.used_attributes.map(&:to_sym))
    end
  end
end
