module Export
  module Pdf
    class Invoice
      class PaymentInformationSection < Base::Section
        def initialize(payment_slip)
          @payment_slip = payment_slip
        end

        def call(pdf)
          pdf.bounding_box([0, 150], width: 300, height: 150) do
            pdf.text 'Zahlungsinformationen', size: 16

            pdf.bounding_box([0, 120], width: 150, height: 120) do
              pdf.text ['Kontonummer', 'Rechnungsbetrag', 'ESR Referenznummer', 'Zugunsten von'].join("\n")
            end
            pdf.bounding_box([150, 120], width: 300, height: 120) do
              pdf.text [@payment_slip.account_nr, format('CHF %<amount>0.2f', amount: @payment_slip.amount),
                        @payment_slip.esr_ref, @payment_slip.payment_information].join("\n")
            end
          end
        end
      end
    end
  end
end
