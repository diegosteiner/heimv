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
  attribute :enable_starttls_auto, :boolean, default: true
  attribute :open_timeout, :integer, default: 5
  attribute :read_timeout, :integer, default: 5

  def self.from_env
    from_value(ENV.fetch('SMTP_SETTINGS'))
  end

  def to_h
    attributes.symbolize_keys
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
