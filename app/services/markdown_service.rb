class MarkdownService
  attr_accessor :body

  def initialize(body)
    @body = body
  end

  def text_body(interpolation_args = {})
    ActionView::Base.full_sanitizer.sanitize(html_body(interpolation_args))
  end

  def html_body(interpolation_args = {})
    interpolation_args = Hash.new { '' }.merge(interpolation_args)
    Kramdown::Document.new(format(body, interpolation_args)).to_html
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  def pdf_body(interpolation_args = {})
    interpolation_args = Hash.new { '' }.merge(interpolation_args)
    format(body, interpolation_args).lines.map do |line|
      # line.gsub!(/__(.+)__/) { '<u>' + Regexp.last_match(1) + '</u>' }
      line.gsub!(/\*\*(.+)\*\*/) { '<b>' + Regexp.last_match(1) + '</b>' }
      # line.gsub!( /%%(.+?)%%/ ) { data[$1] }

      if /^== /.match?(line)
        line.gsub! %r{/^== /}, ''
        next { text: line, style: :bold, size: 25, align: :center }
      elsif /^-- /.match?(line)
        next { text: line, style: :bold, size: 18, align: :center }
      elsif /^#+ /.match?(line)
        line.gsub!(/^#+ /, '')
        next { text: line, style: :bold, size: 15 }
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
end
