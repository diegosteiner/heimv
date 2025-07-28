# frozen_string_literal: true

module Export
  module Taf
    module Blocks
      class Address < Block
        def initialize(**properties, &)
          super(:Adr, **properties, &)
        end

        def self.build_with_tenant(tenant, **properties)
          new(AdrId: Value.cast(tenant.ref, as: :symbol),
              Sort: I18n.transliterate(tenant.full_name).gsub(/\s/, '').upcase,
              Corp: tenant.full_name,
              Lang: 'D',
              Road: tenant.street_address,
              CCode: tenant.country_code,
              ACode: tenant.zipcode,
              City: tenant.city, **properties)
        end
      end
    end
  end
end
