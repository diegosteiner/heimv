module Manage
  class ContractParams < ApplicationParams
    def self.permitted_keys
      %i[sent_at signed_at title text valid_from valid_until booking_id]
    end
  end
end
