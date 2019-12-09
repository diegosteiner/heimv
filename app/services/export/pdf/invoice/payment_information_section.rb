module Export
  module Pdf
    class Invoice
      class PaymentInformationSection < Base::Section
        def initialize(payment_slip)
          @payment_slip = payment_slip
        end

        def render
          bounding_box([0, 160], width: 495, height: 160) do
            stroke_bounds
            render_title
            render_qrcode
            render_payment_information_titles
            render_payment_information
            render_additional_payment_information
          end
        end

        private

        def render_title
          text 'Zahlungsinformationen', size: 16
        end

        def render_payment_information_titles
          bounding_box([180, 120], width: 150, height: 120) do
            text ['Kontonummer', 'Rechnungsbetrag', 'ESR Referenznummer'].join("\n")
          end
        end

        def render_payment_information
          bounding_box([330, 120], width: 260, height: 120) do
            text @payment_slip.esr_participant_nr.to_s
            text format('CHF %<amount>0.2f', amount: @payment_slip.amount)
            text @payment_slip.esr_ref

          end
        end

        def render_additional_payment_information
          bounding_box([180, 160], width: 150, height: 120) do
            stroke_bounds
            Markdown.new(@payment_slip.payment_information).to_pdf.each do |body|
              text body.delete(:text), body.reverse_merge(inline_format: true, size: 8)
            end
          end
        end

        def render_qrcode
          qrcode_image = @payment_slip.qrcode.as_png(bit_depth: 1).to_s

          image StringIO.open(qrcode_image), fit: [135, 135]
        end
      end
    end
  end
end
