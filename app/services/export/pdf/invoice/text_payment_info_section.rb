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

        def markdown_template
          @markdown_template ||= MarkdownTemplate[:text_payment_info_text]
        end

        def markdown_template_body
          @markdown_template_body ||= markdown_template.interpolate('payment_info' => payment_info)
        end

        def render_title
          text markdown_template.title, size: 14
        end

        def height
          140
        end

        def font_size
          10
        end

        def render_text_in_columns
          column_box([0, height - 30], columns: 2, width: bounds.width, height: height) do
            markdown_template_body.to_pdf.each do |body|
              text body.delete(:text), body.reverse_merge(inline_format: true, size: font_size)
            end
          end
        end
      end
    end
  end
end
