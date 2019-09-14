require 'rails_helper'

describe Public::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:booking) { build_stubbed(:booking) }

  describe Public::BookingParams::Create do
    describe '#permit' do
      subject { described_class.permit(params.require(:booking)) }

      it do
        expect(subject).to be_permitted
        expect(subject.to_h.keys).to include('home_id', 'tenant_organisation')
      end
    end
  end

  describe Public::BookingParams::Update do
    describe '#permit_update' do
      subject { described_class.permit(params.require(:booking)) }

      it do
        expect(subject).to be_permitted
        expect(subject.to_h.keys).to include('tenant_organisation')
        expect(subject.to_h.keys).not_to include('home_id')
      end
    end
  end
end
