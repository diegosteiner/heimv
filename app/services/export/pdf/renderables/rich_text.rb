# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class RichText < Renderable
        SUPPORTED_SPECIAL_TOKENS = { PAGE_BREAK: -> { start_new_page }, TARIFS: nil }.freeze
        SUPPORTED_SPECIAL_TOKEN_TAGS = SUPPORTED_SPECIAL_TOKENS.keys.index_by { "{{ #{_1.to_s.upcase} }}" }.freeze

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
            table: { header: { style: :bold, align: :left }, cell: { border_width: 0, padding: [0, 4, 4, 0] } }
          }
        end

        def render
          @document.markup(@body, **markup_options)
        end

        def self.split(body, special_tokens = {})
          return [] if body.blank?

          special_tokens = SUPPORTED_SPECIAL_TOKENS.merge(special_tokens.slice(*SUPPORTED_SPECIAL_TOKENS.keys))
          regexp = Regexp.new("(#{SUPPORTED_SPECIAL_TOKEN_TAGS.keys.join('|')})", 'i')
          body.split(regexp).map do |part|
            special_tokens.fetch(SUPPORTED_SPECIAL_TOKEN_TAGS[part.upcase], new(part))
          end
        end
      end
    end
  end
end
