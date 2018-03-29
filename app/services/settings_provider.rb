class SettingsProvider
  def self.mailer_settings
    scheme, url = ENV.fetch('MAILER_URL').split('://')
    uri = URI(url)
    {
      delivery_method: scheme.to_sym,
      address: uri.host,
      user_name: uri.user,
      password: uri.password,
      port: uri.port
    }.merge(Hash[URI.decode_www_form(uri.query)]).compact.symbolize_keys
  end
end
