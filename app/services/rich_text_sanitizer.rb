# frozen_string_literal: true

class RichTextSanitizer
  def self.sanitize(html)
    sanitizer = Rails::Html::SafeListSanitizer.new
    sanitizer.sanitize(html, { tags: allowed_tags, attributes: allowed_attributes })
  end

  def self.allowed_tags
    Rails::Html::SafeListSanitizer.allowed_tags + %w[table tr td th thead tbody]
  end

  def self.allowed_attributes
    Rails::Html::SafeListSanitizer.allowed_attributes
  end
end
