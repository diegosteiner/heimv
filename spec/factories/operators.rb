# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id              :bigint           not null, primary key
#  contact_info    :text
#  email           :string
#  locale          :string           default("de"), not null
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_operators_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
FactoryBot.define do
  factory :operator do
    name { 'Operator Fourmi' }
    sequence(:email) { |i| "operator_#{i}@heimv.local" }
    contact_info { 'Operator Tel' }
    locale { I18n.locale }
    organisation
  end
end
