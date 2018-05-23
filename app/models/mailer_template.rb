class MailerTemplate < ApplicationRecord
  validates :mailer, :action, presence: true
  delegate :html_body, :text_body, to: :markdown_service

  def markdown_service
    @markdown_service ||= MarkdownService.new(body)
  end
end
