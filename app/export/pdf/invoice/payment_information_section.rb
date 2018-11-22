module Pdf
  class Invoice
    class PaymentInformationSection < Base::Section
      def initialize(payment_slip)
        @payment_slip = payment_slip
      end

      def call(pdf)
        pdf.bounding_box([0, 150], width: 300, height: 150) do

          pdf.text "Zahlungsinformationen", size: 16

          pdf.bounding_box([0, 120], width: 150, height: 120) do
            pdf.text "Kontonummer"
            pdf.text "Rechnungsbetrag"
            pdf.text "ESR Referenznummer"
            pdf.text "Zugunsten von"
          end
          pdf.bounding_box([150, 120], width: 150, height: 120) do
            pdf.text @payment_slip.account_nr
            pdf.text format('CHF %0.2f', @payment_slip.amount)
            pdf.text @payment_slip.esr_ref
            pdf.text @payment_slip.address
          end
        end
      end
    end
  end
end
