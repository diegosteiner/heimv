# frozen_string_literal: true

module Manage
  class TarifParams < ApplicationParams
    def self.permitted_keys
      %i[type label unit price_per_unit ordinal tarif_group accountancy_account home_id
         prefill_usage_method pin minimum_usage_per_night minimum_usage_total] +
        I18n.available_locales.map { |locale| ["label_#{locale}", "unit_#{locale}"] }.flatten +
        [{ associated_types: [],
           selecting_conditions_attributes: BookingConditionParams.permitted_keys + %i[id _destroy] ,
           enabling_conditions_attributes: BookingConditionParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
