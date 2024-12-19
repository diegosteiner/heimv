# frozen_string_literal: true

module Manage
  class InvoicePartSerializer < ApplicationSerializer
    identifier :id

    association :tarif, blueprint: Manage::TarifSerializer
    association :usage, blueprint: Manage::UsageSerializer
    association :vat_category, blueprint: Public::VatCategorySerializer

    fields :amount, :label, :breakdown, :usage_id,
           :accounting_account_nr, :accounting_cost_center_nr, :vat_breakdown

    field :tarif_id do |invoice_part|
      invoice_part.tarif&.id
    end

    field :booking_id do |invoice_part|
      invoice_part.booking&.id
    end
  end
end
