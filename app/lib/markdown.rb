class Markdown
  attr_reader :body
  delegate :to_s, :lines, to: :body

  def initialize(body)
    @body = body || ''
    @engine = Kramdown::Document.new(@body)
  end

  def ==(other)
    body == other.body
  end

  def to_html
    @engine.to_html
  end

  def to_text
    ActionView::Base.full_sanitizer.sanitize(to_html)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def to_pdf
    lines.map do |line|
      line.gsub!(/_(.+)_/) { '<i>' + Regexp.last_match(1) + '</i>' }
      line.gsub!(/\*\*(.+)\*\*/) { '<b>' + Regexp.last_match(1) + '</b>' }
      line.gsub!(/\*(.+)\*/) { '<i>' + Regexp.last_match(1) + '</i>' }
      line.gsub!(/__(.+)__/) { '<b>' + Regexp.last_match(1) + '</b>' }
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
