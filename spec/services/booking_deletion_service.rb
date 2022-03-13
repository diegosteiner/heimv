# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingDeletionService, type: :model do
  let(:organisation) { create(:organisation) }
  subject(:service) { described_class.new(organisation) }

  describe '#delete_all' do
    subject(:ref) { ref_strategy.generate(booking, template) }
    let(:home) { create(:home, organisation: organisation) }
    let(:bookings) { create(:booking, 3, home: home, organisation: organisation) }

    it 'deletes all bookings' do
      bookings
      service.delete_all!
      expect(organisation.bookings.count).to be_zero
    end
  end
end
