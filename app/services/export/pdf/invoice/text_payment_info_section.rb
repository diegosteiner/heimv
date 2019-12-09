module Export
  module Pdf
    class Invoice
      class TextPaymentInfoSection < Base::Section
        attr_reader :payment_info

        def initialize(payment_info)
          @payment_info = payment_info
        end

        def render
          bounding_box([0, 160], width: 495, height: 160) do
            stroke_bounds
            render_title
            render_payment_information
            render_additional_payment_information
          end
        end

        private

        def render_title
          text 'Zahlungsinformationen', size: 16
        end

        def render_payment_information
          bounding_box([0, 140], width: 240, height: 140) do
            label 'Kontonummer'
            text payment_info.esr_participant_nr.to_s
            label 'Rechnungsbetrag'
            text format('CHF %<amount>0.2f', amount: payment_info.amount)
            label 'Referenznummer'
            text payment_info.formatted_ref
          end
        end

        def label(title)
          move_down 2
          text title, size: 8, style: :bold
        end

        def render_additional_payment_information
          bounding_box([250, 140], width: 245, height: 140) do
            stroke_bounds
            Markdown.new(payment_info.organisation.payment_information).to_pdf.each do |body|
              text body.delete(:text), body.reverse_merge(inline_format: true, size: 8)
            end
          end
        end
      end
    end
  end
end
