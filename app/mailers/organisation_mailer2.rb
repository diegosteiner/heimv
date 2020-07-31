class OrganisationMailer2
  def initialize(organisation)
    @organisation = organisation
    @options = {
      from: "#{organisation.name} <#{organisation.email}>",
      reply_to: organisation.email
    }
    @options[:via_options] = SmtpUrl.from_string(organisation.smtp_url) if organisation.smtp_url.present?
  end

  def mail(**args)
    Pony.mail(@options.merge(args))
  end
end
