# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_responsibilities
#
#  id              :bigint           not null, primary key
#  ordinal         :integer
#  remarks         :text
#  responsibility  :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  booking_id      :uuid
#  operator_id     :bigint           not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_operator_responsibilities_on_booking_id       (booking_id)
#  index_operator_responsibilities_on_operator_id      (operator_id)
#  index_operator_responsibilities_on_ordinal          (ordinal)
#  index_operator_responsibilities_on_organisation_id  (organisation_id)
#  index_operator_responsibilities_on_responsibility   (responsibility)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (operator_id => operators.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe OperatorResponsibility, type: :model do
  let(:organisation) { create(:organisation) }
  let(:operator) { create(:operator, organisation:) }
  let(:booking) { create(:booking, organisation:) }

  describe 'booking#responsibilities' do
    let!(:operator_responsibility) do
      create(:operator_responsibility, organisation:, operator:,
                                       responsibility: :home_handover, booking:)
    end

    it 'acts as hash' do
      expect(booking.responsibilities).to eq({ home_handover: operator_responsibility })
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
