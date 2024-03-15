# frozen_string_literal: true

class RichTextSanitizer
  class Scrubber < Loofah::Scrubber
    def scrub(node)
      if node.name == 'script' && node['type'] == 'application/liquid'
        Loofah::Scrubber::CONTINUE
      else
        Loofah::Scrubber::STOP
      end
    end
  end

  def self.sanitize(html)
    sanitizer = Rails::Html::SafeListSanitizer.new
    sanitizer.sanitize(html, { tags: allowed_tags, attributes: allowed_attributes, scrubber: Scrubber.new })
  end

  def self.allowed_tags
    Rails::Html::SafeListSanitizer.allowed_tags + %w[table tr td th thead tbody span]
  end

  def self.allowed_attributes
    Rails::Html::SafeListSanitizer.allowed_attributes + %w[cell-spacing cell-padding]
  end
end
