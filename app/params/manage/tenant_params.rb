# frozen_string_literal: true

module Manage
  class TenantParams < Public::TenantParams
    def self.permitted_keys
      super + %i[reservations_allowed remarks allow_bookings_without_contract]
    end
  end
end
