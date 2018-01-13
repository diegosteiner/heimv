require 'rails_helper'

describe Params::Public::BookingParamsService do
  let(:params_hash) { { booking: build(:booking).attributes } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class.new }

  describe '#call' do
    subject { service.call(params, create_flag) }

    context 'on create' do
      let(:create_flag) { true }
      it do
        is_expected.to be_permitted
        expect(subject.to_h.keys).to include('home_id', 'organisation')
      end
    end

    context 'on update' do
      let(:create_flag) { false }
      it do
        is_expected.to be_permitted
        expect(subject.to_h.keys).to include('organisation')
        expect(subject.to_h.keys).not_to include('home_id')
      end
    end
  end
end
