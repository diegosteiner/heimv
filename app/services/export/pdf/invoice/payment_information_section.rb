module Export
  module Pdf
    class Invoice
      class PaymentInformationSection < Base::Section
        def initialize(payment_slip)
          @payment_slip = payment_slip
        end

        def call(pdf)
          render_title(pdf)
          render_payment_information_titles(pdf)
          render_payment_information(pdf)
          render_qrcode(pdf)
        end

        def render_title(pdf)
          pdf.bounding_box([0, 150], width: 300, height: 150) do
            pdf.text 'Zahlungsinformationen', size: 16
          end
        end

        def render_payment_information_titles(pdf)
          pdf.bounding_box([180, 120], width: 150, height: 120) do
            pdf.text ['Kontonummer', 'Rechnungsbetrag', 'ESR Referenznummer', 'Zugunsten von'].join("\n")
          end
        end

        def render_payment_information(pdf)
          pdf.bounding_box([330, 120], width: 260, height: 120) do
            pdf.text @payment_slip.account_nr.to_s
            pdf.text format('CHF %<amount>0.2f', amount: @payment_slip.amount)
            pdf.text @payment_slip.esr_ref

            render_additional_payment_information(pdf)
          end
        end

        def render_additional_payment_information(pdf)
          Markdown.new(@payment_slip.payment_information).to_pdf.each do |body|
            pdf.text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
          end
        end

        def render_qrcode(pdf)
          qrcode_image = @payment_slip.qrcode.as_png(bit_depth: 1).to_s

          pdf.bounding_box([0, 120], width: 150, height: 150) do
            pdf.image StringIO.open(qrcode_image), fit: [150, 150]
          end
        end
      end
    end
  end
end
