# frozen_string_literal: true

class RichTextSanitizer
  def self.sanitize(html)
    sanitizer = Rails::Html::SafeListSanitizer.new
    sanitizer.sanitize(html, { tags: allowed_tags, attributes: allowed_attributes })
             .gsub(Regexp.new(additional_substitions.keys.join('|')), additional_substitions)
  end

  def self.allowed_tags
    Rails::Html::SafeListSanitizer.allowed_tags + %w[table tr td th thead tbody span liquid]
  end

  def self.allowed_attributes
    Rails::Html::SafeListSanitizer.allowed_attributes + %w[cell-spacing cell-padding]
  end

  def self.additional_substitions
    { '%7B%7B' => '{{', '%7D%7D' => '}}' }
  end
end
