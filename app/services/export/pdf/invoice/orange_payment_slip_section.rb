module Export
  module Pdf
    class Invoice
      class OrangePaymentSlipSection < Base::Section
        attr_reader :payment_info

        def initialize(payment_info)
          @payment_info = payment_info
        end

        def render
          bounding_box([-50, 235], width: 595, height: 295) do
            render_background if render_background?
            render_sender_address
            render_counterfoil_address
            render_amount
            render_esr_participant_nr
            render_esr_ref
            render_code
          end
        end

        protected

        def render_background?
          true
        end

        def render_background
          img = Rails.root.join('app/webpack/images/esr_orange.png')
          image img, width: 595, height: 295, vposition: -4
        end

        def render_sender_address
          [8, 180].each do |x|
            bounding_box([x, 275], width: 150, height: 80) do
              default_leading 1
              text payment_info.organisation.address, size: 8, style: :bold
            end
          end
        end

        def render_esr_participant_nr
          [77, 249].each do |x|
            bounding_box([x, 181], width: 85, height: 10) do
              font('ocr') { text payment_info.esr_participant_nr.to_s }
            end
          end
        end

        def render_amount
          [3, 183].each do |x|
            font('ocr') do
              bounding_box([x, 154], width: 105, height: 14) do
                text format('%<amount>d', amount: payment_info.amount_before_point), size: 12, align: :right
              end

              bounding_box([x + 125, 154], width: 25, height: 14) do
                text format('%<amount>02d', amount: payment_info.amount_after_point), size: 12, align: :center
              end
            end
          end
        end

        def render_counterfoil_address
          [[8, 124], [354, 165]].each do |xy|
            bounding_box(xy, width: 150, height: 60) do
              text payment_info.formatted_ref, size: 8
              move_down 5
              text payment_info.invoice_address, size: 8
            end
          end
        end

        def render_code
          bounding_box([183, 52], width: 395, height: 11) do
            font('ocr', size: 10.5) do
              text payment_info.code_line, align: :right, character_spacing: 0.5
            end
          end
        end

        def render_esr_ref
          bounding_box([354, 204], width: 230, height: 10) do
            font('ocr', size: 10) do
              text payment_info.formatted_ref
            end
          end
        end
      end
    end
  end
end
