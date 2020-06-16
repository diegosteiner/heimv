module Manage
  class BookingAgentParams < ApplicationParams
    def self.permitted_keys
      %i[name code email address provision request_deadline_minutes]
    end
  end
end
