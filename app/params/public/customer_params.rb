module Public
  class CustomerParams < ApplicationParams
    def self.permitted_keys
      %i[first_name last_name street_address zipcode city email]
    end
  end
end
