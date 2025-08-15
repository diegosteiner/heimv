# frozen_string_literal: true

class Invoice
  module Items
    class Balance < Add
      Invoice::Item.register_subtype self

      def vat_category_required?
        false
      end
    end
  end
end
