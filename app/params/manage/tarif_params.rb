# frozen_string_literal: true

module Manage
  class TarifParams < ApplicationParams
    def self.permitted_keys
      %i[type label unit price_per_unit ordinal tarif_group accounting_account_nr accounting_cost_center_nr
         prefill_usage_method prefill_usage_booking_question_id vat_category_id pin
         minimum_usage_per_night minimum_usage_total minimum_price_per_night minimum_price_total] +
        I18n.available_locales.map { |locale| ["label_#{locale}", "unit_#{locale}"] }.flatten +
        [{ associated_types: [],
           selecting_condition_attributes: BookingConditionParams.permitted_keys + %i[id _destroy],
           enabling_condition_attributes: BookingConditionParams.permitted_keys + %i[id _destroy] }]
    end
  end
end
