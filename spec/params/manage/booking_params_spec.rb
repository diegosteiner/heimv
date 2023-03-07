# frozen_string_literal: true

require 'rails_helper'

describe Manage::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes.merge('home_id' => 1) } }
  let(:params) { ActionController::Parameters.new(params_hash) }

  describe '#permit' do
    subject { described_class.new(params.require(:booking)) }

    it do
      expect(subject).to be_permitted
      expect(subject.keys).to include('home_id')
    end
  end
end
