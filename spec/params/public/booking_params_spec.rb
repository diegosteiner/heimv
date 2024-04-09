# frozen_string_literal: true

require 'rails_helper'

describe Public::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes.merge(home_id: 1) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:booking) { build_stubbed(:booking) }

  describe Public::BookingParams::Create do
    subject { described_class.permit(params.require(:booking)) }

    it do
      expect(subject.keys).to include(:home_id, :begins_at, :ends_at, :tenant_organisation)
    end
  end

  describe Public::BookingParams::Update do
    subject { described_class.permit(params.require(:booking)) }

    it do
      expect(subject.keys).to include(:tenant_organisation)
      expect(subject.keys).not_to include(:home_id)
    end
  end
end
