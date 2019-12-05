module Export
  module Pdf
    class Invoice
      class PaymentSlipSection < Base::Section
        def initialize(payment_slip)
          @payment_slip = payment_slip
        end

        def call(pdf)
          pdf.bounding_box([-50, 235], width: 595, height: 295) do
            render_background(pdf)
            render_sender_address(pdf)
            render_counterfoil_address(pdf)
            render_amount(pdf)
            render_esr_participant_nr(pdf)
            render_esr_ref(pdf)
            render_code(pdf)
          end
        end

        def render_background(pdf)
          return if ENV['PRINT_PAYMENT_SLIP_BACKGROUND'].blank?

          img = Rails.root.join('app', 'webpack', 'images', 'esr_orange.png')
          pdf.image img, width: 595
        end

        def render_sender_address(pdf)
          [8, 180].each do |x|
            pdf.bounding_box([x, 275], width: 150, height: 80) do
              pdf.default_leading 1
              pdf.text @payment_slip.address, size: 8, style: :bold
            end
          end
        end

        def render_esr_participant_nr(pdf)
          [77, 249].each do |x|
            pdf.bounding_box([x, 181], width: 85, height: 10) do
              pdf.font('ocr') { pdf.text @payment_slip.esr_participant_nr.to_s }
            end
          end
        end

        def render_amount(pdf)
          [3, 183].each do |x|
            pdf.font('ocr') do
              pdf.bounding_box([x, 154], width: 105, height: 14) do
                pdf.text format('%<amount>d', amount: @payment_slip.amount_before_point), size: 12, align: :right
              end

              pdf.bounding_box([x + 125, 154], width: 25, height: 14) do
                pdf.text format('%<amount>02d', amount: @payment_slip.amount_after_point), size: 12, align: :center
              end
            end
          end
        end

        def render_counterfoil_address(pdf)
          [[8, 124], [354, 165]].each do |xy|
            pdf.bounding_box(xy, width: 150, height: 60) do
              pdf.text @payment_slip.esr_ref, size: 8
              pdf.move_down 5
              pdf.text @payment_slip.invoice_address, size: 8
            end
          end
        end

        def render_code(pdf)
          pdf.bounding_box([183, 52], width: 395, height: 11) do
            pdf.font('ocr', size: 10.5) do
              pdf.text @payment_slip.code_line, align: :right, character_spacing: 0.5
            end
          end
        end

        def render_esr_ref(pdf)
          pdf.bounding_box([354, 204], width: 230, height: 10) do
            pdf.font('ocr', size: 10) do
              pdf.text @payment_slip.esr_ref
            end
          end
        end
      end
    end
  end
end
