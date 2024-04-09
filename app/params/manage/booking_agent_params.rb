# frozen_string_literal: true

module Manage
  class BookingAgentParams < ApplicationParamsSchema
    define do
      optional(:name).maybe(:string)
      optional(:code).maybe(:string)
      optional(:email).maybe(:string)
      optional(:address).maybe(:string)
      optional(:provision).maybe(:string)
      optional(:request_deadline_minutes).maybe(:integer)
    end
  end
end
