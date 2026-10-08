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
#  occupancy_status   :integer          default("pending"), not null
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

  # describe 'conflict symmetry' do
  #   it 'produces the same conflicts regardless of which occupancy runs the validations' do
  #     Occupancy::STATUSES.each_key do |occupancy_status|
  #       expect(Occupancy::STATUS_CONFLICTS[occupancy_status]).to(be_all do
  #         Occupancy::STATUS_CONFLICTS[it].include?(occupancy_status)
  #       end)
  #     end
  #   end
  # end

  describe 'conflict validation' do
    subject(:occupancy) do
      build(:occupancy, organisation:, occupiable: home, occupancy_status:, begins_at:, ends_at:)
    end

    let(:home) { create(:home) }
    let(:organisation) { home.organisation }
    let(:begins_at) { 1.week.from_now }
    let(:ends_at) { 2.weeks.from_now }
    let(:occupancy_status) { :pending }

    ordered_types = %i[free pending tentative occupied closed]
    matrix = {
      free: %w[✅ ✅ ✅ ✅ ✅ ✅],
      pending: %w[✅ ✅ ✅ ✅ 🛑 🛑],
      tentative: %w[✅ ✅ ⏳ ⏳ 🛑 🛑],
      occupied: %w[✅ ✅ ⏳ ⏳ 🛑 🛑],
      closed: %w[✅ ✅ 🛑 🛑 🛑 ✅],
      none: %w[✅ ✅ ✅ ✅ ✅ ✅]
    }

    matrix.each do |occupancy_status, expected_conflicts|
      context "when occupancy is #{occupancy_status}" do
        let(:occupancy_status) { occupancy_status }

        ordered_types.each_with_index do |other_occupancy_status, index|
          context "with an overlapping existing #{other_occupancy_status}" do
            before do
              create(:occupancy, organisation:, occupiable: home, occupancy_status: other_occupancy_status, begins_at:,
                                 ends_at:)
            end

            it 'matches the matrix expectation' do
              if expected_conflicts[index] == '✅'
                expect(occupancy).to be_valid
              else
                expect(occupancy).not_to be_valid
                expect(occupancy.errors).to be_added(:base, :occupancy_conflict)
              end
            end
          end
        end
      end
    end
  end
end
