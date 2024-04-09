# frozen_string_literal: true

module Manage
  class PaymentParams < ApplicationParamsSchema
    define do
      optional(:amount).filled(:decimal)
      optional(:invoice_id).maybe(:integer)
      optional(:booking_id).maybe(:string)
      optional(:paid_at).filled(:string)
      optional(:ref).maybe(:string)
      optional(:data).maybe(:string)
      optional(:remarks).maybe(:string)
      optional(:applies).filled(:bool)
      optional(:confirm).filled(:bool)
      optional(:write_off).filled(:bool)
      optional(:camt_instr_id).maybe(:string)
    end
  end
end
