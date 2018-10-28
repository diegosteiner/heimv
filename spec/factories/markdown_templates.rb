FactoryBot.define do
  factory :markdown_template do
    ref { [BookingStateMailer.to_s, :test].join('/') }
    title { 'Test' }
    locale { I18n.available_locales.sample }
    subject { 'Test Template' }
    body { Faker::Lorem.paragraph }
  end
end
