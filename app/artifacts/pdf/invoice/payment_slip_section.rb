module Pdf
  class Invoice
    class PaymentSlipSection < Base::Section
      def initialize(invoice)
        @invoice = invoice
      end

      def call(pdf)
        render_code(pdf)
        render_esr_number(pdf)
      end

      def render_code(pdf)
        pdf.bounding_box([130, -4], width: 395, height: 10.2) do
          pdf.font('ocr', size: 10.2) do
            pdf.text @invoice.payment_slip_code
          end
        end
      end

      def render_esr_number(pdf)
        pdf.bounding_box([295, 147], width: 235, height: 10) do
          pdf.font('ocr', size: 10) do
            pdf.text @invoice.ref
          end
        end
      end
    end
  end
end
