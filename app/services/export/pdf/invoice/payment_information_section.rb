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
              render_payment_information(pdf)
            end
          end
        end

        def render_payment_information(pdf)
          pdf.text @payment_slip.account_nr.to_s
          pdf.text format('CHF %<amount>0.2f', amount: @payment_slip.amount)
          pdf.text @payment_slip.esr_ref

          Markdown.new(@payment_slip.payment_information).to_pdf.each do |body|
            pdf.text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
          end
        end
      end
    end
  end
end
