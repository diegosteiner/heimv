# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id              :bigint           not null, primary key
#  contact_info    :text
#  email           :string
#  locale          :string           not null
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
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
