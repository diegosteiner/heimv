# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id                 :uuid             not null, primary key
#  begins_at          :datetime         not null
#  color              :string
#  ends_at            :datetime         not null
#  ignore_conflicting :boolean          default(FALSE), not null
#  linked             :boolean          default(TRUE)
#  occupancy_type     :integer          default("pending"), not null
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  occupiable_id      :bigint           not null
#

require 'rails_helper'

RSpec.describe Occupancy do
  describe '#nights' do
    subject { occupancy.nights }

    context 'with 0 nights' do
      let(:occupancy) { build(:occupancy, begins_at: '2018-08-21 11:00', ends_at: '2018-08-21 23:00') }

      it { is_expected.to be 0 }
    end

    context 'with 1 night' do
      let(:occupancy) { build(:occupancy, begins_at: '2018-08-21 22:00', ends_at: '2018-08-22 11:00') }

      it { is_expected.to be 1 }
    end

    context 'with 2 nights' do
      let(:occupancy) { build(:occupancy, begins_at: '2018-08-21 11:00', ends_at: '2018-08-23 23:00') }

      it { is_expected.to be 2 }
    end
  end

  describe 'conflict validation' do
    subject(:occupancy) do
      build(:occupancy, organisation:, occupiable: home, occupancy_type:, begins_at:, ends_at:)
    end

    let(:home) { create(:home) }
    let(:organisation) { home.organisation }
    let(:begins_at) { 1.week.from_now }
    let(:ends_at) { 2.weeks.from_now }

    before do
      create(:occupancy, organisation:, occupiable: home, occupancy_type: :occupied, begins_at:, ends_at:)
    end

    context 'when occupancy is pending' do
      let(:occupancy_type) { :pending }

      it 'is valid despite overlap' do
        expect(occupancy).to be_valid
      end
    end

    context 'when occupancy is occupied' do
      let(:occupancy_type) { :occupied }

      it 'is invalid with occupancy_conflict' do
        expect(occupancy).not_to be_valid
        expect(occupancy.errors).to be_added(:base, :occupancy_conflict)
      end
    end
  end
end
