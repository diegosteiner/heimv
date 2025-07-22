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
require 'rails_helper'

RSpec.describe OAuthToken do # rubocop:disable RSpec/SpecFilePathFormat
  let(:organisation) { create(:organisation) }
  let(:oauth_token) do
    described_class.create!(organisation:, audience: :smtp, expires_at: 50.minutes.ago,
                            access_token:, refresh_token:,
                            client_id:, client_secret:,
                            authorize_url: 'https://accounts.google.com/o/oauth2/auth',
                            token_url: 'https://oauth2.googleapis.com/token')
  end

  describe '#refreshed_token', skip: 'needs to be stubbed' do
    it 'refreshes the token' do
      expect(oauth_token.refreshed_token).to be_a(OAuth2::AccessToken)
    end
  end
end
