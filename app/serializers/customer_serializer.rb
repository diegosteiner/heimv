class CustomerSerializer < ApplicationSerializer
  attributes *%i[first_name last_name street_address zipcode city email]
end
