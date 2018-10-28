class MarkdownTemplate < ApplicationRecord
  validates :key, :locale, presence: true
  validates :key, uniqueness: true
  delegate :html_body, :text_body, to: :markdown_service

  def markdown_service
    @markdown_service ||= MarkdownService.new(body)
  end

  def self.key(klass, key)
    [klass.to_s, key].join('/')
  end
end
