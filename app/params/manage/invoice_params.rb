# frozen_string_literal: true

module Manage
  class InvoiceParams < ApplicationParams
    def self.permitted_keys
      %i[type text booking_id issued_at sent_at payable_until ref payment_info_type
         supersede_invoice_id payment_required locale] +
        [{ items: { array: %i[usage_id label breakdown amount type ordinal_position vat_category_id
                              accounting_account_nr accounting_cost_center_nr id apply _destroy] } }]
    end

    sanitize do |params|
      params[:text] = RichTextSanitizer.sanitize(params[:text]) if params[:text].present?
      params
    end
  end
end
