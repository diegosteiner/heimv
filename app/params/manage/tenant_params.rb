# frozen_string_literal: true

module Manage
  class TenantParams < Public::TenantParams
    def self.permitted_keys
      super + %i[reservations_allowed]
    end
  end
end
