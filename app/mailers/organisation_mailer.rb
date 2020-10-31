# frozen_string_literal: true

class OrganisationMailer
  def initialize(organisation)
    @organisation = organisation
    @options = {
      from: (organisation.mail_from || organisation.name),
      reply_to: organisation.email
    }
    @options[:via_options] = SmtpConfig.from_string(organisation.smtp_url.presence || ENV.fetch('SMTP_URL'))
  end

  def mail(**args)
    Rails.logger.info "SMTP Mail to #{args[:to]} [#{@organisation.name}] #{args.inspect}"
    Pony.mail(@options.merge(args))
  end
end
