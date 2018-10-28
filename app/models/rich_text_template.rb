class RichTextTemplate < ApplicationRecord
  validates :klass, :variant, :locale, presence: true
  validates :variant, uniqueness: { scope: %i[klass locale] }
  delegate :html_body, :text_body, to: :markdown_service

  def markdown_service
    @markdown_service ||= MarkdownService.new(body)
  end
end
