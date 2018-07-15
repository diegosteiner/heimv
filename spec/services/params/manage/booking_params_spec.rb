require 'rails_helper'

describe Manage::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:service) { described_class }

  describe '#permit' do
    subject { service.permit(params.require(:booking)) }

    it do
      is_expected.to be_permitted
      expect(subject.to_h.keys).to include('home_id')
    end
  end
end
