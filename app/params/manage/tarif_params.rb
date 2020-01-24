module Manage
  class TarifParams < ApplicationParams
    def permit_update_all(params)
      params.dig(:home).permit(tarifs_attributes: (self.class.permitted_keys + [:id]))[:tarifs_attributes]
    end

    def self.permitted_keys
      %i[type label unit price_per_unit position tarif_group invoice_type prefill_usage_method transient meter] +
        [{ tarif_selectors_attributes: TarifSelectorParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
