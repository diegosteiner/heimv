# frozen_string_literal: true

# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body            :text
#  key             :string
#  locale          :string
#  namespace       :string
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_markdown_templates_on_home_id          (home_id)
#  index_markdown_templates_on_key_composition  (key,locale,organisation_id,home_id,namespace) UNIQUE
#  index_markdown_templates_on_namespace        (namespace)
#  index_markdown_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
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
