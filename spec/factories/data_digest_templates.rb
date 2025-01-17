# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#

FactoryBot.define do
  factory :data_digest_template do
    organisation
    prefilter_params { '' }
    label { Faker::Name.name }
    type { DataDigestTemplates::Booking }
    factory :booking_data_digest_template, class: 'DataDigestTemplates::Booking'
    factory :payment_data_digest_template, class: 'DataDigestTemplates::Payment'
    factory :invoice_part_data_digest_template, class: 'DataDigestTemplates::InvoicePart'
  end
end
