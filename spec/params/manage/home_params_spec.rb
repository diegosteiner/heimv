require 'rails_helper'

describe Manage::HomeParams do
  let(:params_hash) { { home: attributes_for(:home) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class }

  describe '#permit' do
    subject { service.permit(params.require(:home)) }

    it do
      expect(subject).to be_permitted
      expect(subject.to_h).to include(name: params_hash.dig(:home, :name))
    end
  end
end
