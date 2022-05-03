# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id                 :bigint           not null, primary key
#  body_i18n          :jsonb
#  body_i18n_markdown :jsonb
#  enabled            :boolean          default(TRUE)
#  key                :string
#  title_i18n         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  home_id            :bigint
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_rich_text_templates_on_home_id                        (home_id)
#  index_rich_text_templates_on_key_and_home_and_organisation  (key,home_id,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id                (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

FactoryBot.define do
  factory :rich_text_template do
    organisation
    title { 'Test' }
    sequence(:key) { |i| "template_#{i}" }
    body { Faker::Lorem.paragraph }
  end

  factory :email_template, parent: :rich_text_template
end
