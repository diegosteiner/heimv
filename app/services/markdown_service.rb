class MarkdownService
  attr_accessor :body

  def initialize(body)
    @body = body
  end

  def text_body(interpolation = {})
    ActionView::Base.full_sanitizer.sanitize(html_body(interpolation))
  end

  def html_body(interpolation = {})
    Kramdown::Document.new(format(body, interpolation)).to_html
  end

  def pdf_body
    # body.lines.map do |line|
    # line.gsub!( /__(.+)__/ ) { '<u>' + $1 + '</u>' }
    # line.gsub!( /%%(.+?)%%/ ) { data[$1] }
    # if line.match /^== /
    # line.gsub! /^== /, ""
    # indent(20) do
    # text line, style: :bold, size: 25, align: :center
    # end
    # elsif line.match /^-- /
    # line.gsub! /^-- /, ""
    # text line, style: :bold, size: 18, align: :center
    # elsif line.match /^### /
    # line.gsub! /^### /, ""
    # text line, style: :bold, size: 16
    # elsif line.match /^\s*[A-Z]\. /
    # indent(30) do
    # text line, :indent_paragraphs => -15, inline_format: true, final_gap: true
    # end
    # elsif line.match /^\s*\d{1,2}\. /
    # indent(30) do
    # text line, :indent_paragraphs => -15, inline_format: true
    # end
    # elsif line.match /^\s*[a-z]\. /
    # indent(50) do
    # text line, :indent_paragraphs => -15, inline_format: true
    # end
  end
end
