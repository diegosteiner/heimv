# frozen_string_literal: true

module Manage
  class TarifSerializer < ApplicationSerializer
    fields :label, :pin, :prefill_usage_method, :price_per_unit, :tarif_group, :type, :unit, :ordinal,
           :label_i18n, :unit_i18n, :valid_from, :valid_until, :accounting_account_nr,
           :minimum_usage_per_night, :minimum_usage_total

    field :associated_types do |tarif|
      tarif.associated_types.to_a
    end

    view :export do
      include_view :default
    end
  end
end
