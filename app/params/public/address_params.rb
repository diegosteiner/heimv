# frozen_string_literal: true

module Public
  class AddressParams < ApplicationParams
    def self.permitted_keys
      %i[recipient suffix representing street street_nr postalcode city country_code]
    end
  end
end
