module Export
  module Pdf
    class Invoice
      class TextPaymentInfoSection < Base::Section
        attr_reader :payment_info

        def initialize(payment_info)
          @payment_info = payment_info
        end

        def render
          bounding_box([0, height], width: bounds.width, height: height) do
            render_title
            render_text_in_columns
          end
        end

        protected

        def render_title
          text payment_info.title, size: 14
        end

        def height
          140
        end

        def font_size
          10
        end

        def render_text_in_columns
          column_box([0, height - 30], columns: 2, width: bounds.width, height: height) do
            payment_info.body.to_pdf.each do |body|
              text body.delete(:text), body.reverse_merge(inline_format: true, size: font_size)
            end
          end
        end
      end
    end
  end
end
