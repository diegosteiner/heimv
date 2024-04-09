# frozen_string_literal: true

module Manage
  class InvoiceParams < ApplicationParamsSchema
    define do
      optional(:type).filled(:string)
      optional(:text).maybe(:string)
      optional(:booking_id).filled(:string)
      optional(:issued_at).maybe(:date)
      optional(:sent_at).maybe(:date_time)
      optional(:payable_until).maybe(:date_time)
      optional(:ref).maybe(:string)
      optional(:payment_info_type).filled(:string)
      optional(:supersede_invoice_id).maybe(:integer)
      optional(:locale).filled(:string)
      optional(:invoice_parts_attributes).hash(InvoicePartParams.new) do
        required(:id).filled(:integer)
        optional(:apply).filled(:bool)
        optional(:_destroy).maybe(:bool)
      end

      after(:rule_applier) do |result|
        result.to_h.tap do |params|
          params[:text] = RichTextSanitizer.sanitize(params[:text])
        end
      end
    end
  end
end
