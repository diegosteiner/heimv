# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    delivery_method_settings = DeliveryMethodSettings.new(ENV['MAILER_URL'])
    ActionMailer::Base.delivery_method = delivery_method_settings.delivery_method
    ActionMailer::Base.try(delivery_method_settings.method, delivery_method_settings.to_h)
  end
  default from: Rails.application.secrets.mail_from
  layout 'mailer'

  def markdown_mail(to, subject, markdown, options = {})
    mail(to: to, subject: subject, cc: options.fetch(:cc, []), bcc: options.fetch(:bcc, [])) do |format|
      format.text { markdown.to_text }
      format.html { markdown.to_html }
    end
  end
end
