# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Usage::Factory, type: :model do
  let(:booking) { create(:booking, initial_state: :awaiting_contract) }
  let(:organisation) { booking.organisation }
  let(:builder) { described_class.new(booking) }

  describe '#build' do
    subject { builder.build }

    let!(:used_tarif) { create(:tarif, organisation: organisation, pin: true) }
    let!(:tarifs) { create_list(:tarif, 3, organisation: organisation, pin: true) }
    let!(:existing_usage) { create(:usage, booking: booking, tarif: used_tarif) }

    it do
      expect(subject).to(be_all { |actual| actual.is_a?(Usage) })
      tarif_ids = subject.map(&:tarif_id)
      expect(tarif_ids).to include(*tarifs.map(&:id))
      expect(tarif_ids).not_to include(existing_usage.id)
    end
  end
end
