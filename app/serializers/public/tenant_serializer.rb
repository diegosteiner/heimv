module Public
  class TenantSerializer < ApplicationSerializer
    attributes :first_name, :last_name, :street_address, :zipcode, :city, :email
  end
end
