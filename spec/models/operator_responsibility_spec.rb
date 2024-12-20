# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id              :integer          not null, primary key
#  booking_id      :uuid
#  operator_id     :integer          not null
#  ordinal         :integer
#  responsibility  :integer
#  remarks         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :integer          not null
#
# Indexes
#
#  index_operator_responsibilities_on_booking_id       (booking_id)
#  index_operator_responsibilities_on_operator_id      (operator_id)
#  index_operator_responsibilities_on_ordinal          (ordinal)
#  index_operator_responsibilities_on_organisation_id  (organisation_id)
#  index_operator_responsibilities_on_responsibility   (responsibility)
#

require 'rails_helper'

RSpec.describe OperatorResponsibility, type: :model do
  let(:organisation) { create(:organisation) }
  let(:operator) { create(:operator, organisation:) }
  let(:booking) { create(:booking, organisation:) }

  describe 'booking#roles' do
    let!(:operator_responsibility) do
      create(:operator_responsibility, organisation:, operator:,
                                       responsibility: :home_handover, booking:)
    end

    it 'acts as hash' do
      expect(booking.roles).to eq({ home_handover: operator_responsibility, administration: organisation,
                                    tenant: booking.tenant })
    end
  end

  describe '::assign' do
    subject(:responsibility) { described_class.assign(booking, :administration)&.first }

    context 'with defined responsibilities' do
      before do
        create_list(:operator_responsibility, 4, organisation:, operator:,
                                                 responsibility: :administration, booking: nil,
                                                 assigning_conditions: [BookingConditions::AlwaysApply.new])
      end

      it { is_expected.to be_valid }
      it { expect(responsibility.booking).to eq(booking) }
      it { expect(responsibility).to be_administration }
    end

    context 'with existing operator_responsibilities' do
      before do
        4.times do
          booking = create(:booking, organisation:)
          create(:operator_responsibility, organisation:, responsibility: :home_handover,
                                           operator:, booking:)
        end
      end

      it { is_expected.to be_nil }
    end
  end
end
