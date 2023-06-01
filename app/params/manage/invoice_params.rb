# frozen_string_literal: true

module Manage
  class InvoiceParams < ApplicationParams
    def self.permitted_keys
      %i[type text booking_id issued_at sent_at payable_until ref payment_info_type supersede_invoice_id] +
        [:locale, { invoice_parts_attributes: InvoicePartParams.permitted_keys + %i[id apply _destroy] }]
    end

    sanitize do |params|
      params[:text] = RichTextSanitizer.sanitize(params[:text]) if params[:text].present?
      params
    end
  end
end
