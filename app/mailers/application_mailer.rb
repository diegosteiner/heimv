# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    SettingsProvider.mailer_settings.tap do |settings|
      Rails.logger.debug settings.inspect
      ActionMailer::Base.delivery_method = settings.fetch(:delivery_method)
      ActionMailer::Base.try(ActionMailer::Base.delivery_method.to_s + '_settings=', settings)
      # default from: settings.fetch(:from, 'no-reply@heimverwaltung.localhost')
    end
  end
  default from: Rails.application.secrets.mail_from
  layout 'mailer'

  def markdown_mail(to, subject, markdown)
    mail(to: to, subject: subject) do |format|
      format.text { markdown.to_text }
      format.html { markdown.to_html }
    end
  end

  def mail_from_template(key, _interpolator, options = {})
    template = MarkdownTemplate.find_by(interpolatable_type: self.class.to_s, key: key, locale: I18n.locale)
    return unless template

    mail(options.merge(subject: template.title)) do |format|
      format.text { template.text_body(interpolation_params) }
      format.html { template.html_body(interpolation_params) }
    end
  end
end
