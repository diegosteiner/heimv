require 'rails_helper'

describe Params::Manage::HomeParams do
  let(:params_hash) { { home: attributes_for(:home) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class.new }

  describe '#call' do
    subject { service.call(params) }

    it do
      is_expected.to be_permitted
      expect(subject.to_h).to include(name: params_hash.dig(:home, :name))
    end
  end
end
