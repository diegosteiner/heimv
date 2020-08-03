# frozen_string_literal: true

class OrganisationMailer
  def initialize(organisation)
    @organisation = organisation
    @options = {
      from: "#{organisation.name} <#{organisation.mail_from}>",
      reply_to: organisation.email
    }
    @options[:via_options] = SmtpUrl.from_string(organisation.smtp_url) if organisation.smtp_url.present?
  end

  def mail(**args)
    Rails.logger.info "SMTP Mail to #{args[:to]} [#{@organisation.name}]"
    Pony.mail(@options.merge(args))
  end
end
