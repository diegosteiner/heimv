require 'rails_helper'

describe Admin::UserParams do
  let(:params_hash) { { user: attributes_for(:user) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class }

  describe '#permit' do
    subject { service.permit(params.require(:user)) }

    it do
      expect(subject).to be_permitted
      expect(subject.to_h).to include(email: params_hash.dig(:user, :email))
    end
  end
end
