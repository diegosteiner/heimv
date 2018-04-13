FactoryBot.define do
  factory :mailer_template do
    mailer { BookingStateMailer.to_s }
    action :test
    locale { I18n.available_locales.sample }
    subject 'Test Template'
    body { Faker::Lorem.paragraph }
  end
end
