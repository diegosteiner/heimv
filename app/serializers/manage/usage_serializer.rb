# frozen_string_literal: true

module Manage
  class UsageSerializer < ApplicationSerializer
    identifier :id
    association :tarif, blueprint: Manage::TarifSerializer

    fields :used_units, :price, :remarks, :tarif_id, :committed, :price_per_unit, :minimum_price, :included_units,
           :billable_units
  end
end
