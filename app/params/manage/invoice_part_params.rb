module Manage
  class InvoicePartParams < ApplicationParams
    def self.permitted_keys
      %i[usage_id label label_2 amount type position]
    end
  end
end
