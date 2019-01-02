module Public
  class TenantParams < ApplicationParams
    def self.permitted_keys
      %i[first_name last_name street_address zipcode city email birth_date]
    end
  end
end
