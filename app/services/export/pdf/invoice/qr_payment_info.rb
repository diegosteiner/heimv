module Export
  module Pdf
    class Invoice
      class QrPaymentInfoSection < Base::Section
        def initialize(payment_slip)
          @payment_slip = payment_slip
        end

        def render
          bounding_box([0, 160], width: 495, height: 160) do
            render_title
            render_qrcode
          end
        end

        private

        def render_title
          text 'Zahlungsinformationen', size: 16
        end

        def render_qrcode
          qrcode_image = @payment_slip.qrcode.as_png(bit_depth: 1).to_s

          image StringIO.open(qrcode_image), fit: [135, 135]
        end
      end
    end
  end
end
