# frozen_string_literal: true

module Manage
  class ContractParams < ApplicationParamsSchema
    define do
      optional(:sent_at).maybe(:date)
      optional(:signed_at).maybe(:date_time)
      optional(:title).maybe(:string)
      optional(:text).maybe(:string)
      optional(:valid_from).maybe(:date_time)
      optional(:valid_until).maybe(:date_time)
      optional(:booking_id).filled(:string)
      optional(:signed_pdf).value(type?: ActionDispatch::Http::UploadedFile)
      optional(:locale).filled(:string)
      after(:rule_applier) do |result|
        result.to_h.tap do |params|
          params[:text] = RichTextSanitizer.sanitize(params[:text])
        end
      end
    end
  end
end
