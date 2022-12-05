# frozen_string_literal: true

module Manage
  class TarifSerializer < ApplicationSerializer
    fields :label, :pin, :prefill_usage_method, :price_per_unit, :tarif_group, :type, :unit, :ordinal,
           :label_i18n, :unit_i18n, :valid_from, :valid_until, :home_id

    field :associated_types do |tarif|
      tarif.associated_types.to_a
    end

    view :export do
      include_view :default
    end
  end
end
