require 'rails_helper'

describe Params::Public::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class.new }
  let(:booking) { build_stubbed(:booking) }

  describe '#call' do
    subject { service.call(params, booking) }

    context 'on create' do
      before { allow(booking).to receive(:new_record?).and_return(true) }
      it do
        is_expected.to be_permitted
        expect(subject.to_h.keys).to include('home_id', 'organisation')
      end
    end

    context 'on update' do
      before { allow(booking).to receive(:new_record?).and_return(false) }
      it do
        is_expected.to be_permitted
        expect(subject.to_h.keys).to include('organisation')
        expect(subject.to_h.keys).not_to include('home_id')
      end
    end

    skip do
      context 'with unpermitted tranistion_value' do
        # expect
      end
    end
  end
end
