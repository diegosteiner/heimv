# frozen_string_literal: true

module Public
  class TenantParams < ApplicationParams
    def self.permitted_keys
      %i[first_name last_name street_address zipcode city email birth_date country phone]
    end
  end
end
