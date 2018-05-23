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
end
