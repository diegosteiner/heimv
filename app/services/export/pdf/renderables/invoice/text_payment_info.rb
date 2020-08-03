# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      module Invoice
        class TextPaymentInfo < Renderable
          attr_reader :payment_info

          def initialize(payment_info)
            @payment_info = payment_info
          end

          def render
            start_new_page if cursor < height

            bounding_box([0, height], width: bounds.width, height: height) do
              render_title
              render_text_in_columns
            end
          end

          protected

          def render_title
            text payment_info.title, size: font_size + 2
          end

          def height
            140
          end

          def font_size
            9
          end

          def render_text_in_columns
            column_box([0, height - 30], columns: 2, width: bounds.width, height: height) do
              Export::Pdf::Renderables::Markdown.to_prawn_text(@payment_info.body).each do |body|
                text body.delete(:text), body.reverse_merge(inline_format: true, size: font_size)
              end
            end
          end
        end
      end
    end
  end
end
