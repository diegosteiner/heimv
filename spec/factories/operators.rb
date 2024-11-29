# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id              :integer          not null, primary key
#  name            :string
#  email           :string
#  contact_info    :text
#  organisation_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  locale          :string           not null
#
# Indexes
#
#  index_operators_on_organisation_id  (organisation_id)
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
