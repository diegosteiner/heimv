# frozen_string_literal: true

module Manage
  class InvoicePartSerializer < ApplicationSerializer
    association :tarif, blueprint: Manage::TarifSerializer
    association :usage, blueprint: Manage::UsageSerializer
    association :invoice, blueprint: Manage::InvoiceSerializer

    fields :amount, :label, :breakdown
  end
end
