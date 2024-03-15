# frozen_string_literal: true

module Manage
  class MeterReadingPeriodSerializer < ApplicationSerializer
    identifier :id
    association :tarif, blueprint: Manage::TarifSerializer
    association :usage, blueprint: Manage::UsageSerializer
    fields :begins_at, :end_value, :ends_at, :start_value, :tarif_id, :usage_id
  end
end
