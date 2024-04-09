# frozen_string_literal: true

module Manage
  class TenantParams < Public::TenantParams::Create
    define do
      optional(:reservations_allowed).filled(:bool)
      optional(:remarks).maybe(:string)
      optional(:bookings_without_contract).filled(:bool)
      optional(:bookings_without_invoice).filled(:bool)
    end
  end
end
