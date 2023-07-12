# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  committed           :boolean          default(FALSE)
#  presumed_used_units :decimal(, )
#  price_per_unit      :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#
# Indexes
#
#  index_usages_on_booking_id               (booking_id)
#  index_usages_on_tarif_id_and_booking_id  (tarif_id,booking_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (tarif_id => tarifs.id)
#

require 'rails_helper'

RSpec.describe Usage, type: :model do
  let(:organisation) { create(:organisation) }
  let(:tarif) { create(:tarif, organisation: organisation, price_per_unit: 3.33) }

  describe '#price' do
    let(:usage) { build(:usage, tarif: tarif, used_units: 2) }
    subject { usage.price }

    it { is_expected.to eq(6.65) }
  end

  describe Usage::Factory do
    describe 'build' do
      let(:booking) { create(:booking, organisation: organisation, approximate_headcount: 12) }
      subject(:usages) { factory.build(preselect: true) }
      subject(:factory) { Usage::Factory.new(booking) }
      before do
        BookingConditions::OccupancyDuration.create(qualifiable: tarif, group: :selecting, compare_value: '1d',
                                                    compare_operator: :>)
        BookingConditions::BookingAttribute.create(qualifiable: tarif, group: :selecting, compare_value: '10',
                                                   compare_attribute: :approximate_headcount, compare_operator: :>)
        BookingConditions::BookingAttribute.create(qualifiable: tarif, group: :selecting, compare_value: 'test',
                                                   compare_attribute: :tenant_organisation, must_condition: false)
      end

      it do
        expect(usages.count).to be > 0
        usage = usages.first
        expect(usage.apply).to be true
        expect(usage.tarif).to eq(tarif)
      end
    end
  end

  describe '#save' do
    let(:booking) { create(:booking) }
    let(:usage) { build(:usage, booking: booking, tarif: tarif) }

    it { expect(usage.save!).to be true }
  end
end
