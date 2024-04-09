# frozen_string_literal: true

module Manage
  class InvoicePartParams < ApplicationParamsSchema
    define do
      optional(:usage_id).maybe(:integer)
      optional(:label).filled(:string)
      optional(:breakdown).maybe(:string)
      optional(:amount).maybe(:decimal)
      optional(:type).filled(:string)
      optional(:ordinal_position).maybe(:string)
      optional(:vat).maybe(:decimal)
    end
  end
end
