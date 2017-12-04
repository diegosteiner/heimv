require 'rails_helper'

describe Params::UserParamsService do
  let(:params_hash) { { user: attributes_for(:user) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:current_user) { build(:user) }
  let(:service) { described_class.new(params, current_user) }

  describe '#process' do
    subject { service.process }

    it do
      is_expected.to be_permitted
      expect(subject.to_h).to include(email: params_hash.dig(:user, :email))
    end
  end
end
