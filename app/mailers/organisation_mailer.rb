# frozen_string_literal: true

class OrganisationMailer
  def initialize(organisation)
    @organisation = organisation
    @options = {
      from: (organisation.mail_from || organisation.email),
      reply_to: organisation.email,
      charset: 'UTF-8'
    }
    @options[:via_options] = SmtpSettings.from_h_or_default(organisation.smtp_settings).symbolize_keys
  end

  def mail(**args)
    Rails.logger.info "SMTP Mail to #{args[:to]} [#{@organisation.name}] #{args.inspect}"
    Pony.mail(@options.merge(args))
  end
end
