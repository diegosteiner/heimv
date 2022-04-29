# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class RichText < Renderable
        def initialize(body)
          super()
          @body = body.is_a?(::Markdown) ? body.to_html : body
        end

        def markup_options
          {
            list: { content: { leading: 5 } },
            heading1: { style: :bold, size: 16, margin_top: 10, margin_bottom: 2 },
            heading2: { style: :bold, size: 14, margin_top: 10, margin_bottom: 2 },
            heading3: { style: :bold, size: 12, margin_top: 10, margin_bottom: 2 },
            heading4: { style: :bold, size: 10, margin_top: 10, margin_bottom: 2 },
            heading5: { style: :bold, margin_top: 10, margin_bottom: 2 },
            heading6: { style: :bold, margin_top: 10, margin_bottom: 2 },
            table: { cell: { border_width: 0 } }
          }
        end

        def render
          @document.markup(@body, **markup_options)
        end
      end
    end
  end
end
