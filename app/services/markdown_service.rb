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
    Kramdown::Document.new(format(body, interpolation)).to_html
  end

  def pdf_body(interpolation_args = {})
    interpolation_args = Hash.new { '' }.merge(interpolation_args)
    format(body, interpolation_args).lines.map do |line|
      line.gsub!( /__(.+)__/ ) { '<u>' + $1 + '</u>' }
      line.gsub!( /\*\*(.+)\*\*/ ) { '<b>' + $1 + '</b>' }
      # line.gsub!( /%%(.+?)%%/ ) { data[$1] }

      if line.match /^== /
        line.gsub! /^== /, ''
        next { text: line, style: :bold, size: 25, align: :center }
      elsif line.match /^-- /
        next { text: line, style: :bold, size: 18, align: :center }
      elsif line.match /^#+ /
        line.gsub!( /^#+ /, '')
        next { text: line, style: :bold, size: 15 }
      elsif line.match /^\s*[A-Z]\. /
        next { text: line, final_gap: true }
      elsif line.match /^\s*\d{1,2}\. /
        next { text: line, :indent_paragraphs => -15 }
      elsif line.match /^\s*[a-z]\. /
        next { text: line, :indent_paragraphs => -15 }
      else
        next { text: line, inline_format: true }
      end
    end.compact
  end
end
