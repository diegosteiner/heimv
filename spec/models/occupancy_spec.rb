# frozen_string_literal: true

# == Schema Information
#
# Table name: occupancies
#
#  id                 :uuid             not null, primary key
#  begins_at          :datetime         not null
#  color              :string
#  conflict_type      :integer          default("pending"), not null
#  ends_at            :datetime         not null
#  ignore_conflicting :boolean          default(FALSE), not null
#  linked             :boolean          default(TRUE)
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  calendar_label_id  :bigint
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
  #     Occupancy::CONFLICT_TYPES.each_key do |conflict_type|
  #       expect(Occupancy::CONFLICTS[conflict_type]).to(be_all do
  #         Occupancy::CONFLICTS[it].include?(conflict_type)
  #       end)
  #     end
  #   end
  # end

  describe 'conflict validation' do
    subject(:occupancy) do
      build(:occupancy, organisation:, occupiable: home, conflict_type:, begins_at:, ends_at:)
    end

    let(:home) { create(:home) }
    let(:organisation) { home.organisation }
    let(:begins_at) { 1.week.from_now }
    let(:ends_at) { 2.weeks.from_now }
    let(:conflict_type) { :pending }

    ordered_types = %i[free pending tentative occupied closed]
    matrix = {
      free: %w[✅ ✅ ✅ ✅ ✅ ✅],
      pending: %w[✅ ✅ ✅ ✅ 🛑 🛑],
      tentative: %w[✅ ✅ ⏳ ⏳ 🛑 🛑],
      occupied: %w[✅ ✅ ⏳ ⏳ 🛑 🛑],
      closed: %w[✅ ✅ 🛑 🛑 🛑 ✅],
      void: %w[✅ ✅ ✅ ✅ ✅ ✅]
    }

    matrix.each do |conflict_type, expected_conflicts|
      context "when occupancy is #{conflict_type}" do
        let(:conflict_type) { conflict_type }

        ordered_types.each_with_index do |other_conflict_type, index|
          context "with an overlapping existing #{other_conflict_type}" do
            before do
              create(:occupancy, organisation:, occupiable: home, conflict_type: other_conflict_type, begins_at:,
                                 ends_at:)
            end

            it 'matches the matrix expectation' do
              if expected_conflicts[index] == '✅'
                expect(occupancy).to be_valid
              else
                expect(occupancy).not_to be_valid
                expect(occupancy.errors.full_messages_for(:base))
                  .to contain_exactly(I18n.t('activerecord.errors.messages.occupancy_conflict', occupiable: home.name))
              end
            end
          end
        end
      end
    end
  end
end
