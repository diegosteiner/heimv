class MailerTemplate < ApplicationRecord
  validates :mailer, :action, presence: true

  def text_body(interpolation = {})
    ActionView::Base.full_sanitizer.sanitize(html_body(interpolation))
  end

  def html_body(interpolation = {})
    Kramdown::Document.new(format(body, interpolation)).to_html
  end
end
