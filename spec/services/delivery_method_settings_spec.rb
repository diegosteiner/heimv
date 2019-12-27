require 'rails_helper'

RSpec.describe DeliveryMethodSettings, type: :model do
  let(:settings_url) { nil }
  let(:settings) { described_class.new(settings_url) }

  context 'when settings_url is nil' do
    let(:settings_url) { nil }
    it 'handles nil' do
      expect(settings.delivery_method).to be_nil
      expect(settings.to_h).to eq({})
    end
  end

  context 'when settings_url is valid' do
    let(:settings_url) { 'smtp://username:password@host.example:1234?from=no-reply@heimv.local&user_name=username_2' }
    it 'handles nil' do
      expect(settings.delivery_method).to eq(:smtp)
      expect(settings.to_h).to eq(
        user_name: 'username_2',
        password: 'password',
        address: 'host.example',
        port: 1234,
        from: 'no-reply@heimv.local'
      )
    end
  end
end
