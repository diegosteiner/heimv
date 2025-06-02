# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmtpSettings do
  subject(:settings) { organisation.smtp_settings }

  let(:settings_hash) { {} }
  let(:organisation) { create(:organisation) }

  before { organisation.smtp_settings = settings_hash }

  describe 'valid?' do
    it { is_expected.to be_valid }
  end

  describe '#to_config' do
    context 'with authentication: :xoauth2' do
      subject(:to_config) { settings.to_config }

      let(:settings_hash) { { authentication: :xoauth2 } }
      let!(:access_token) do
        OAuthToken.create!(organisation:, expires_at: 1.hour.from_now, access_token: 'tokenliteral12', audience: :smtp)
      end

      it 'uses the token as a password' do
        is_expected.to include({ authentication: 'xoauth2', password: be_a(Proc) })
        expect(settings.xoauth2_token).to eq(access_token)
        expect(to_config[:password].call).to eq(access_token.access_token)
      end
    end
  end
end
