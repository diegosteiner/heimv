# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  autodeliver     :boolean          default(TRUE)
#  body_i18n       :jsonb
#  enabled         :boolean          default(TRUE)
#  key             :string
#  title_i18n      :jsonb
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#

FactoryBot.define do
  factory :rich_text_template do
    organisation
    title { 'Test' }
    sequence(:key) { |i| "template_#{i}" }
    body { Faker::Lorem.paragraph }
  end

  factory :mail_template, parent: :rich_text_template, class: MailTemplate.to_s
end
