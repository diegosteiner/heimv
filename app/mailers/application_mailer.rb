# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    SettingsProvider.mailer_settings.tap do |settings|
      ActionMailer::Base.delivery_method = settings.fetch(:delivery_method)
      ActionMailer::Base.try(ActionMailer::Base.delivery_method.to_s + '_settings=', settings)
    end
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
