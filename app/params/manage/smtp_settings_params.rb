# frozen_string_literal: true

module Manage
  class SmtpSettingsParams < ApplicationParams
    def self.permitted_keys
      %i[address user_name password port ssl tls authentication enable_starttls open_timeout read_timeout]
    end
  end
end
