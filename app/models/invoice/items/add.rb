# frozen_string_literal: true

class Invoice
  module Items
    class Add < ::Invoice::Item
      Invoice::Item.register_subtype self

      def calculated_amount
        amount
      end
    end
  end
end
