# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Markdown < Renderable
        def initialize(markdown)
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
        # rubocop:disable Metrics/PerceivedComplexity
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/BlockLength
        # rubocop:disable Metrics/AbcSize
        def self.to_prawn_text(body)
          body.lines.map do |line|
            line.gsub!(/_(.+)_/) { '<i>' + Regexp.last_match(1) + '</i>' }
            line.gsub!(/\*\*(.+)\*\*/) { '<b>' + Regexp.last_match(1) + '</b>' }
            line.gsub!(/\*(.+)\*/) { '<i>' + Regexp.last_match(1) + '</i>' }
            line.gsub!(/__(.+)__/) { '<b>' + Regexp.last_match(1) + '</b>' }
            # line.gsub!( /%%(.+?)%%/ ) { data[$1] }

            if /^== /.match?(line)
              line.gsub! %r{/^== /}, ''
              next { text: line, style: :bold, size: 24, align: :center }
            elsif /^-- /.match?(line)
              next { text: line, style: :bold, size: 16, align: :center }
            elsif /^#####+ /.match?(line)
              line.gsub!(/^#+ /, '')
              next { text: line, style: :bold }
            elsif /^####+ /.match?(line)
              line.gsub!(/^#+ /, '')
              next { text: line, style: :bold, size: 9 }
            elsif /^###+ /.match?(line)
              line.gsub!(/^###+ /, '')
              next { text: line, style: :bold, size: 10 }
            elsif /^##+ /.match?(line)
              line.gsub!(/^##+ /, '')
              next { text: line, style: :bold, size: 12 }
            elsif /^#+ /.match?(line)
              line.gsub!(/^#+ /, '')
              next { text: line, style: :bold, size: 14 }
            elsif /^\s*[A-Z]\. /.match?(line)
              next { text: line, final_gap: true }
            elsif /^\s*\d{1,2}\. /.match?(line)
              next { text: line, indent_paragraphs: -15 }
            elsif /^\s*[a-z]\. /.match?(line)
              next { text: line, indent_paragraphs: -15 }
            else
              next { text: line, inline_format: true }
            end
          end.compact
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/BlockLength
      end
    end
  end
end
