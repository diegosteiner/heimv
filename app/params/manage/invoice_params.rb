# frozen_string_literal: true

module Manage
  class InvoiceParams < ApplicationParams
    def self.permitted_keys
      %i[type text booking_id issued_at sent_at payable_until ref payment_info_type] +
        [{ invoice_parts_attributes: InvoicePartParams.permitted_keys + %i[id apply _destroy] }]
    end

    sanitize do |params|
      sanitizer = Rails::Html::SafeListSanitizer.new
      params[:text] = sanitizer.sanitize(params[:text])
      params
    end
  end
end
