# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmtpSettings, type: :model do
  describe '#from_json' do
    subject { described_class.from_json(value) }

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
