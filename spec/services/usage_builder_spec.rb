# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Usage::Factory, type: :model do
  let(:booking) { create(:booking, initial_state: :awaiting_contract, home: home) }
  let(:builder) { described_class.new(booking) }

  describe '#build' do
    subject { builder.build }

    let(:home) { create(:home) }
    let!(:used_home_tarif) { create(:tarif, home: home, pin: true) }
    let!(:home_tarifs) { create_list(:tarif, 3, home: home, pin: true) }
    let!(:booking_tarifs) { create_list(:tarif, 4) }
    let!(:existing_usage) { create(:usage, booking: booking, tarif: used_home_tarif) }

    it do
      expect(subject).to(be_all { |actual| actual.is_a?(Usage) })
      tarif_ids = subject.map(&:tarif_id)
      expect(tarif_ids).to include(*home_tarifs.map(&:id))
      # expect(tarif_ids).to include(*booking_tarifs.map(&:id))
      expect(tarif_ids).not_to include(existing_usage.id)
      # expect(tarif_ids).to include(existing_usage.tarif.id)
    end
  end
end
