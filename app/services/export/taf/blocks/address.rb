# frozen_string_literal: true

module Export
  module Taf
    module Blocks
      class Address < Block
        def initialize(**properties, &)
          super(:Adr, **properties, &)
        end

        def self.build_with_tenant(tenant, **properties)
          build_with_address(tenant.address,
                             AdrId: Value.cast(tenant.ref, as: :symbol),
                             Sort: I18n.transliterate(tenant.full_name).gsub(/\s/, '').upcase,
                             **properties)
        end

        def self.build_with_address(address, **properties)
          new(AdrId: nil, Sort: nil,
              Corp: address.recipient,
              Lang: 'D',
              Road: address.street_line,
              CCode: address.country_code,
              ACode: address.postalcode,
              City: address.city, **properties)
        end
      end
    end
  end
end
