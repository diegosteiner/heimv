require 'rails_helper'

RSpec.describe Usage::Factory, type: :model do
  let(:booking) { create(:booking, initial_state: :confirmed, home: home) }
  let(:builder) { described_class.new(booking) }

  describe '#build' do
    let(:home) { create(:home) }
    let!(:used_home_tarif) { create(:tarif, home: home, transient: true) }
    let!(:home_tarifs) { create_list(:tarif, 3, home: home, transient: true) }
    let!(:booking_tarifs) { create_list(:tarif, 4, :for_booking, booking: booking) }
    let!(:existing_usage) { create(:usage, booking: booking, tarif: used_home_tarif) }

    subject { builder.build }

    it do
      is_expected.to(be_all { |actual| actual.is_a?(Usage) })
      tarif_ids = subject.map(&:tarif_id)
      expect(tarif_ids).to include(*home_tarifs.map(&:id))
      # expect(tarif_ids).to include(*booking_tarifs.map(&:id))
      expect(tarif_ids).not_to include(existing_usage.id)
      # expect(tarif_ids).to include(existing_usage.tarif.id)
    end
  end
end
