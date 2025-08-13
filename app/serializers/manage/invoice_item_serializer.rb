# frozen_string_literal: true

module Manage
  class InvoiceItemSerializer < ApplicationSerializer
    identifier :id

    association :tarif, blueprint: Manage::TarifSerializer
    association :usage, blueprint: Manage::UsageSerializer
    association :vat_category, blueprint: Public::VatCategorySerializer

    fields :amount, :label, :breakdown, :usage_id, :suggested, :apply, :vat_category_id,
           :accounting_account_nr, :accounting_cost_center_nr, :vat_breakdown

    field :type do |item|
      item.type
    end

    field :tarif_id do |item|
      item.usage&.tarif_id
    end

    field :booking_id do |item|
      item.booking&.id
    end
  end
end
