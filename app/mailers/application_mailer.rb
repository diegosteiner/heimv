# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  default from: -> { SmtpSettings.from_env[:from] || ENV.fetch('MAIL_FROM', nil) || 'test@heimv.local' },
          bcc: -> { SmtpSettings.from_env[:bcc] || ENV.fetch('MAIL_BCC', nil) }
end
