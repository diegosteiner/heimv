# frozen_string_literal: true

require 'rails_helper'

describe Manage::BookingParams do
  let(:params_hash) { { booking: build(:booking).attributes.merge('home_id' => 1) } }

  describe '#permit' do
    subject { described_class.permit(params[:booking]) }

    it do
      expect(subject.keys).to include(:home_id)
    end
  end
end
