# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  default from: -> { SmtpSettings.from_env[:from] || ENV['MAIL_FROM'] || 'test@heimv.local' },
          bcc: -> { SmtpSettings.from_env[:bcc] || ENV['MAIL_BCC'] }
end
