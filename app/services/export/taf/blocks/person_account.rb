# frozen_string_literal: true

module Export
  module Taf
    module Blocks
      class PersonAccount < Block
        def initialize(**properties, &)
          super(:PKd, **properties, &)
        end

        def self.build_with_tenant(tenant, **override)
          account_nr = Value.cast(tenant.ref, as: :symbol)

          new(PkKey: account_nr, AdrId: account_nr,
              AccId: Value.cast(tenant.organisation.accounting_settings.debitor_account_nr, as: :symbol),
              ZabId: '15T', **override)
        end
      end
    end
  end
end
