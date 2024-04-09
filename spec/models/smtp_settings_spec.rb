# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmtpSettings, type: :model do
  describe '#from_json' do
    subject { described_class.from_json(value).to_h }

    let(:value) do
      '{"address": "heimv.test","port": 587,"user_name": "smtpuser@heimv.test", "password": "secret"}'
    end

    it {
      expect(subject).to include(
        address: 'heimv.test',
        user_name: 'smtpuser@heimv.test',
        password: 'secret',
        port: 587
      )
    }
  end
end
