# frozen_string_literal: true

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
#  organisation_id :bigint           not null
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
    title { 'Test' }
    locale { I18n.available_locales.sample }
    sequence(:key) { |i| "key-#{i}" }
    body { Faker::Lorem.paragraph }
  end
end
