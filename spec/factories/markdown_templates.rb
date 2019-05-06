# == Schema Information
#
# Table name: markdown_templates
#
#  id         :bigint           not null, primary key
#  key        :string
#  title      :string
#  locale     :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :markdown_template do
    ref { [BookingStateMailer.to_s, :test].join('/') }
    title { 'Test' }
    locale { I18n.available_locales.sample }
    subject { 'Test Template' }
    body { Faker::Lorem.paragraph }
  end
end
