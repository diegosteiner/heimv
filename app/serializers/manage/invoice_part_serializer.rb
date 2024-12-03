# frozen_string_literal: true

module Manage
  class InvoicePartSerializer < ApplicationSerializer
    association :tarif, blueprint: Manage::TarifSerializer
    association :usage, blueprint: Manage::UsageSerializer
    association :vat_category, blueprint: Public::VatCategorySerializer

    fields :amount, :label, :breakdown, :usage_id

    field :tarif_id do |invoice_part|
      invoice_part.tarif&.id
    end

    field :booking_id do |invoice_part|
      invoice_part.booking&.id
    end
  end
end
