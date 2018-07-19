module Manage
  class InvoicePartParams < ApplicationParams
    def self.permitted_keys
      %i[usage_id text amount type row_order_position]
    end
  end
end
