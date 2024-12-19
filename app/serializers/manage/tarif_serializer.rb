# frozen_string_literal: true

module Manage
  class TarifSerializer < ApplicationSerializer
    identifier :id
    association :vat_category, blueprint: Public::VatCategorySerializer

    fields :label, :pin, :prefill_usage_method, :price_per_unit, :tarif_group, :type, :unit, :ordinal,
           :label_i18n, :unit_i18n, :valid_from, :valid_until, :vat_category_id,
           :accounting_account_nr, :accounting_cost_center_nr,
           :minimum_usage_per_night, :minimum_usage_total, :minimum_price_per_night, :minimum_price_total

    field :associated_types do |tarif|
      tarif.associated_types.to_a
    end

    view :export do
      include_view :default
    end
  end
end
