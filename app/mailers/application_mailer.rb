# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  if ActionMailer::Base.delivery_method.nil?
    delivery_method_settings = DeliveryMethodSettings.new(ENV['MAILER_URL'])
    ActionMailer::Base.delivery_method = delivery_method_settings.delivery_method
    ActionMailer::Base.try(delivery_method_settings.method, delivery_method_settings.to_h)
  end
  default from: ENV['MAIL_FROM']
  layout 'mailer'

  def markdown_mail(organisation, markdown, options = {})
    organisation_mail(organisation, options) do |format|
      format.text { markdown.to_text }
      format.html { markdown.to_html }
    end
  end

  def organisation_mail(organisation, options = {}, &block)
    mail(options.merge(
           from: (organisation.delivery_method_settings[:from] || ENV['MAIL_FROM']),
           bcc: organisation.delivery_method_settings[:bcc],
           delivery_method_options: organisation.delivery_method_settings.to_h
         ), &block)
  end
end
