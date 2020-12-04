# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Markdown < Renderable
        def initialize(markdown)
          super()
          @markdown = markdown.is_a?(::Markdown) ? markdown : ::Markdown.new(markdown)
        end

        # TODO: use https://github.com/blocknotes/prawn-styled-text
        def render
          move_down 10
          self.class.to_prawn_text(@markdown.body).each do |body|
            text body.delete(:text), body.reverse_merge(inline_format: true)
          end
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/BlockLength
        # rubocop:disable Metrics/AbcSize
        def self.to_prawn_text(body)
          body.lines.map do |line|
            line.gsub!(/_(.+)_/) { "<i>#{Regexp.last_match(1)}</i>" }
            line.gsub!(/\*\*(.+)\*\*/) { "<b>#{Regexp.last_match(1)}</b>" }
            line.gsub!(/\*(.+)\*/) { "<i>#{Regexp.last_match(1)}</i>" }
            line.gsub!(/__(.+)__/) { "<b>#{Regexp.last_match(1)}</b>" }
            # line.gsub!( /%%(.+?)%%/ ) { data[$1] }

            case line
            when /^== /
              line.gsub! %r{/^== /}, ''
              next { text: line, style: :bold, size: 24, align: :center }
            when /^-- /
              next { text: line, style: :bold, size: 16, align: :center }
            when /^#####+ /
              line.gsub!(/^#+ /, '')
              next { text: line, style: :bold }
            when /^####+ /
              line.gsub!(/^#+ /, '')
              next { text: line, style: :bold, size: 9 }
            when /^###+ /
              line.gsub!(/^###+ /, '')
              next { text: line, style: :bold, size: 10 }
            when /^##+ /
              line.gsub!(/^##+ /, '')
              next { text: line, style: :bold, size: 12 }
            when /^#+ /
              line.gsub!(/^#+ /, '')
              next { text: line, style: :bold, size: 14 }
            when /^\s*[a-zA-Z]\. /
              next { text: line, final_gap: true }
            when /^\s*\d{1,2}\. /
              next { text: line, indent_paragraphs: -15 }
            else
              next { text: line, inline_format: true }
            end
          end.compact
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/BlockLength
      end
    end
  end
end
