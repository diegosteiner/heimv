# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id               :bigint           not null, primary key
#  distinction      :string
#  group            :string
#  must_condition   :boolean          default(TRUE)
#  qualifiable_type :string
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint
#  qualifiable_id   :bigint
#
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe BookingConditions::OccupancyDuration, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate(booking) }
    let(:distinction) { '' }
    let(:booking_condition) { described_class.new(distinction: distinction, organisation: organisation) }
    let(:organisation) { create(:organisation) }
    let(:booking) do
      create(:booking, begins_at: 4.weeks.from_now, ends_at: 5.weeks.from_now, organisation: organisation)
    end

    it { is_expected.to be_falsy }

    context 'with non-matching condition' do
      let(:distinction) { '<8h' }
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_falsy }
    end

    context 'with matching condition' do
      let(:distinction) { '>1d' }
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end
end
