require 'rails_helper'

describe Params::HomeParamsService do
  let(:params_hash) { { home: attributes_for(:home) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:current_user) { build(:user) }
  let(:service) { described_class.new(params, current_user) }

  describe '#process' do
    subject { service.process }

    it do
      is_expected.to be_permitted
      expect(subject.to_h).to include(name: params_hash.dig(:home, :name))
    end
  end
end
