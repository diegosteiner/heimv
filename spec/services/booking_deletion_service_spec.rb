# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingDeletionService, type: :model do
  subject(:service) { described_class.new(organisation) }

  let(:organisation) { create(:organisation) }

  describe '#delete_all' do
    subject(:ref) { ref_strategy.generate(booking, template) }

    let(:home) { create(:home, organisation:) }
    let(:bookings) { create_list(:booking, 3, home:, organisation:) }

    it 'deletes all bookings' do
      bookings
      service.delete_all!
      expect(organisation.bookings.count).to be_zero
    end
  end
end
