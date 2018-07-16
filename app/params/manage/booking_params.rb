module Manage
  class BookingParams < Public::BookingParams::Create
    def self.permitted_keys
      super + %i{transition_to}
    end
  end
end
