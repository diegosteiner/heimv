# frozen_string_literal: true

class Markdown
  attr_reader :body
  delegate :to_s, :lines, to: :body

  def initialize(body)
    @body = body || ''
    @engine = Kramdown::Document.new(@body)
  end

  def ==(other)
    body == other.body if other.respond_to?(:body)
    body == other if other.is_a?(String)
    false
  end

  def to_html
    @engine.to_html
  end

  def to_text
    ActionView::Base.full_sanitizer.sanitize(to_html)
  end
end
