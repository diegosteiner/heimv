# frozen_string_literal: true

class SmtpSettings
  include StoreModel::Model

  attribute :address, :string
  attribute :user_name, :string
  attribute :password, :string
  attribute :port, :integer, default: 25
  attribute :ssl, :boolean, default: false
  attribute :tls, :boolean, default: false
  attribute :authentication, :string
  attribute :enable_starttls, default: -> { 'auto' }
  attribute :open_timeout, :integer, default: 5
  attribute :read_timeout, :integer, default: 5

  def self.from_env
    from_value(ENV.fetch('SMTP_SETTINGS'))
  end

  def to_h
    # :enable_starttls and :tls are mutually exclusive. Set :tls if you're on an SMTPS connection.
    # Set :enable_starttls if you're on an SMTP connection and using STARTTLS for secure TLS upgrade
    if tls || ssl
      attributes.symbolize_keys.except(:enable_starttls)
    else
      attributes.symbolize_keys.except(:tls, :ssl)
    end
  end

  def to_config
    case authentication&.to_s&.upcase
    when 'XOAUTH2'
      to_h.merge({ password: -> { xoauth2_token&.refreshed_token&.token } })
    else
      to_h
    end
  end

  def xoauth2_token
    parent.oauth_tokens.find_by(audience: :smtp)
  end
end
