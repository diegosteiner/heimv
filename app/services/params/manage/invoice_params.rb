module Params
  module Manage
    class InvoiceParams < ApplicationParams
      def call(params)
        params.require(:invoice).permit(*self.class.permitted_params)
      end

      def self.permitted_params
        %i[invoice_type text issued_at payable_until esr_number]
      end
    end
  end
end
