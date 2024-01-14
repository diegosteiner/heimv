# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IcalService, type: :model do
  subject(:service) { described_class.new }

  describe '#occupancies_to_ical' do
    subject(:occupancies_to_ical) { service.occupancies_to_ical(bookings.flat_map(&:occupancies)) }

    let(:organisation) { create(:organisation) }
    let(:home) { create(:home, organisation:) }
    let(:bookings) do
      create_list(:booking, 3, organisation:, home:, occupiables: [home])
    end

    it 'generates the ics file' do
      expect(occupancies_to_ical).to be_present
    end
  end
end
