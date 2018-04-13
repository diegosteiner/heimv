require 'rails_helper'

describe Params::Admin::UserParams do
  let(:params_hash) { { user: attributes_for(:user) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class.new }

  describe '#permit' do
    subject { service.permit(params) }

    it do
      is_expected.to be_permitted
      expect(subject.to_h).to include(email: params_hash.dig(:user, :email))
    end
  end
end
