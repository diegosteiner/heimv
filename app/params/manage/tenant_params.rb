# frozen_string_literal: true

module Manage
  class TenantParams < Public::TenantParams
    def self.permitted_keys
      super + %i[reservations_allowed remarks bookings_without_contract bookings_without_invoice]
    end
  end
end
