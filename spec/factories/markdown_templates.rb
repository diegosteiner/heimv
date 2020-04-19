# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body            :text
#  key             :string
#  locale          :string
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           default(1), not null
#
# Indexes
#
#  index_markdown_templates_on_key_and_locale_and_organisation_id  (key,locale,organisation_id) UNIQUE
#  index_markdown_templates_on_organisation_id                     (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  factory :markdown_template do
    organisation
    ref { [BookingStateMailer.to_s, :test].join('/') }
    title { 'Test' }
    locale { I18n.available_locales.sample }
    subject { 'Test Template' }

    body { Faker::Lorem.paragraph }
  end
end
