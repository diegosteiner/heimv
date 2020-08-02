# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Markdown < Renderable
        def initialize(markdown)
          @markdown = markdown.is_a?(::Markdown) ? markdown : ::Markdown.new(markdown)
        end

        def render
          move_down 10
          @markdown.to_pdf.each do |body|
            text body.delete(:text), body.reverse_merge(inline_format: true)
          end
        end
      end
    end
  end
end
