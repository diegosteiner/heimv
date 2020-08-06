# frozen_string_literal: true

require 'rails_helper'

describe Manage::HomeParams do
  let(:params_hash) { { home: attributes_for(:home) } }
  let(:params) { ActionController::Parameters.new(params_hash) }

  describe '#permit' do
    subject { described_class.new(params.require(:home)) }

    it do
      expect(subject).to be_permitted
      expect(subject.to_h).to include(name: params_hash.dig(:home, :name))
    end
  end
end
