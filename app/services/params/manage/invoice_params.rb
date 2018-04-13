module Params
  module Manage
    class InvoiceParams < ApplicationParams
      def permit(params)
        params.require(:invoice).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        %i[invoice_type text issued_at payable_until esr_number]
      end
    end
  end
end
