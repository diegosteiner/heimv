# frozen_string_literal: true

require 'rails_helper'

describe Public::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes.merge(home_id: 1) } }
  let(:params) { ActionController::Parameters.new(params_hash) }
  let(:booking) { build_stubbed(:booking) }

  describe Public::BookingParams::Create do
    subject(:params_object) { described_class.new(params.require(:booking)) }

    it do
      is_expected.to be_permitted
      is_expected.to have_attributes(keys: include('home_id', 'begins_at', 'ends_at', 'tenant_organisation'))
    end
  end

  describe Public::BookingParams::Update do
    subject(:params_object) { described_class.new(params.require(:booking)) }

    it do
      is_expected.to be_permitted
      is_expected.to have_attributes(keys: include('tenant_organisation'))
      is_expected.not_to have_attributes(keys: include('home_id'))
    end
  end
end
