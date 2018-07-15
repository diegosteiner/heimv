module Manage
  class CustomerParams < Public::CustomerParams
    def self.permitted_keys
      super + %i[reservations_allowed]
    end
  end
end
