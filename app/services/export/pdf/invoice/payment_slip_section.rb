module Export
  module Pdf
    class Invoice
      class PaymentSlipSection < Base::Section
        def initialize(payment_slip)
          @payment_slip = payment_slip
        end

        def call(pdf)
          pdf.bounding_box([-50, 255], width: 595, height: 305) do
            render_background(pdf)
            render_address(pdf)
            render_amount(pdf)
            render_account_nr(pdf)
            render_code(pdf)
            render_esr_number(pdf)
          end
        end

        def render_background(pdf)
          return if ENV['PRINT_PAYMENT_SLIP_BACKGROUND'].blank?

          img = Rails.root.join('app', 'webpack', 'images', 'esr_orange.png')
          pdf.image img, width: 595
        end

        def render_address(pdf)
          [8, 180].each do |x|
            pdf.bounding_box([x, 275], width: 150, height: 80) do
              pdf.default_leading 1
              pdf.text @payment_slip.address, size: 8, style: :bold
            end
          end
        end

        def render_account_nr(pdf)
          [77, 249].each do |x|
            pdf.bounding_box([x, 181], width: 85, height: 10) do
              pdf.font('ocr') { pdf.text @payment_slip.account_nr.to_s }
            end
          end
        end

        def render_amount(pdf)
          [5, 178].each do |x|
            pdf.font('ocr') do
              pdf.bounding_box([x, 157], width: 111, height: 14) do
                pdf.text format('%<amount>d', amount: @payment_slip.amount_before_point), size: 12, align: :right
              end

              pdf.bounding_box([x + 130, 157], width: 25, height: 14) do
                pdf.text format('%<amount>02d', amount: @payment_slip.amount_after_point), size: 12, align: :center
              end
            end
          end
        end

        def render_code(pdf)
          pdf.bounding_box([195, 60], width: 380, height: 11) do
            pdf.font('ocr', size: 10.2) do
                pdf.text @payment_slip.code_line, align: :right, character_spacing: 0.75
            end
          end
        end

        def render_esr_number(pdf)
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
