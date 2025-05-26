# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_tokens
#
#  id              :bigint           not null, primary key
#  access_token    :string
#  audience        :integer          not null
#  authorize_url   :string
#  client_secret   :string
#  expires_at      :datetime
#  refresh_token   :string
#  token_type      :string
#  token_url       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :string
#  organisation_id :bigint           not null
#
FactoryBot.define do
  factory :oauth_token do
    organisation { nil }
    access_token { 'MyString' }
    expires_at { 'MyString' }
    refresh_token { 'MyString' }
    token_type { 'MyString' }
    issuer { 'MyString' }
    refresh_url { 'MyString' }
    audience { 'MyString' }
  end
end
