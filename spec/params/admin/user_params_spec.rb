# frozen_string_literal: true

require 'rails_helper'

describe Admin::UserParams do
  let(:params_hash) { { user: attributes_for(:user) } }
  let(:params) { ActionController::Parameters.new(params_hash) }

  describe '#permit' do
    subject { described_class.new(params.require(:user)) }

    it do
      expect(subject).to be_permitted
      expect(subject.to_h).to include(email: params_hash.dig(:user, :email))
    end
  end
end
