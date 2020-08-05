# frozen_string_literal: true

class SmtpUrl
  def self.from_string(value)
    URI(value).instance_eval do
      options = URI.decode_www_form(query || '').to_h
      {
        address: host,
        user_name: user,
        password: password,
        port: port,
        method: scheme&.to_sym
      }.merge(options).compact.symbolize_keys
    end
  end

  def self.from_env(_default)
    from_string(ENV.fetch('SMTP_URL'))
  end
end

module URI
  class SMTP < Generic
    DEFAULT_PORT = 25
  end
  @@schemes['SMTP'] = SMTP
end
