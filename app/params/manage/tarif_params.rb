# frozen_string_literal: true

module Manage
  class TarifParams < ApplicationParams
    def permit_update_all(params)
      params[:home].permit(tarifs_attributes: (self.class.permitted_keys + [:id]))[:tarifs_attributes]
    end

    def self.permitted_keys
      %i[type label unit price_per_unit ordinal tarif_group invoice_type
         tenant_visible prefill_usage_method transient] +
        I18n.available_locales.map { |locale| ["label_#{locale}", "unit_#{locale}"] }.flatten +
        [{ tarif_selectors_attributes: TarifSelectorParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
