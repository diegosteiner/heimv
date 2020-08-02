# frozen_string_literal: true

Pony.options = if Rails.env.test?
                 {
                   from: ENV.fetch('MAIL_FROM', 'test@heimv.local'),
                   via: :test
                 }
               else
                 {
                   from: ENV.fetch('MAIL_FROM', 'test@heimv.local'),
                   via: :smtp,
                   via_options: SmtpUrl.from_string(ENV.fetch('SMTP_URL'))
                 }
               end
