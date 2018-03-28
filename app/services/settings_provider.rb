class SettingsProvider
  def self.mailer_settings
    {
      from: ENV['MAIL_FROM'] || ''
    }
  end

  def self.mailer_smtp_settings
    uri = URI(ENV['MAILER_URL'])
    {
      address: uri.host,
      user_name: uri.user,
      password: uri.password,
      port: uri.port
    }.merge(Hash[URI.decode_www_form(uri.query)])
  rescue StandardError
    {}
  end
end
