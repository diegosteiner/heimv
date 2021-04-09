# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Markdown < Renderable
        def initialize(markdown)
          super()
          @markdown = markdown.is_a?(::Markdown) ? markdown : ::Markdown.new(markdown)
        end

        def markup_options
          {
            heading1: { style: :bold, size: 16, margin_top: 10, margin_bottom: 2 },
            heading2: { style: :bold, size: 14, margin_top: 10, margin_bottom: 2 },
            heading3: { style: :bold, size: 12, margin_top: 10, margin_bottom: 2 },
            heading4: { style: :bold, size: 10, margin_top: 10, margin_bottom: 2 },
            heading5: { style: :bold, margin_top: 10, margin_bottom: 2 },
            heading6: { style: :bold, margin_top: 10, margin_bottom: 2 }
          }
        end

        def render
          @document.markup(@markdown.to_html, **markup_options)
        end
      end
    end
  end
end
