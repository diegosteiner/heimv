# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  default from: -> { ENV.fetch('MAIL_FROM', 'test@heimv.local') },
          bcc: -> { ENV['MAIL_BCC'] }
end
