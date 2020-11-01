# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmtpConfig, type: :model do
  describe '#from_string' do
    subject { described_class.from_string(value) }

    context 'with url' do
      let(:value) { 'smtp://example.com:587?user_name=smtpuser@example.com&password=secret' }

      it {
        is_expected.to eq({
                            address: 'example.com',
                            user_name: 'smtpuser@example.com',
                            password: 'secret',
                            port: 587,
                            method: :smtp
                          })
      }
    end

    context 'with json' do
      let(:value) do
        '{"address": "example.com","port": 587,"user_name": "smtpuser@example.com", "password": "secret"}'
      end

      it {
        is_expected.to eq({
                            address: 'example.com',
                            user_name: 'smtpuser@example.com',
                            password: 'secret',
                            port: 587,
                            method: :smtp
                          })
      }
    end
  end
end
