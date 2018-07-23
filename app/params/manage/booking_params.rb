module Manage
  class BookingParams < Public::BookingParams::Create
    def self.permitted_keys
      super + %i[transition_to] + [usages_attributes: UsageParams.permitted_keys + %i[_destroy id]]
    end
  end
end
