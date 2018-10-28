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

  def mail_from_template(action, interpolation_params, options = {})
    template = RichTextTemplate.where(mailer: self.class.to_s, action: action).take
    return unless template

    mail(options.merge(subject: template.subject)) do |format|
      format.text { template.text_body(interpolation_params) }
      format.html { template.html_body(interpolation_params) }
    end
  end
end
