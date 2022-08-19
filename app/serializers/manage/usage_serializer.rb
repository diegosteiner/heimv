# frozen_string_literal: true

module Manage
  class UsageSerializer < ApplicationSerializer
    association :tarif, blueprint: Manage::TarifSerializer

    fields :used_units, :price
  end
end
