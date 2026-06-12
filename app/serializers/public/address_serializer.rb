# frozen_string_literal: true

module Public
  class AddressSerializer < ApplicationSerializer
    fields :recipient, :suffix, :representing, :street, :street_nr, :postalcode, :city, :country_code, :lines, :to_s
  end
end
