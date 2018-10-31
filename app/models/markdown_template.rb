class MarkdownTemplate < ApplicationRecord
  validates :key, :locale, presence: true
  validates :key, uniqueness: true

  def interpolate(interpolation_source)
    @interpolate ||= MarkdownService::Markdown.new(I18n.interpolate(body, InterpolationService.call(interpolation_source)))
  end

  def self.composite_key(*partial_keys)
    partial_keys.join('/')
  end
end
