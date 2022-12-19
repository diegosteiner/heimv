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

RSpec.describe BookingConditions::BookingState, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate(booking) }
    let(:booking_condition) { described_class.new(distinction: distinction, organisation: organisation) }
    let(:organisation) { create(:organisation) }
    let(:distinction) { 'open_request' }

    context 'with different state' do
      let(:booking) { create(:booking, organisation: organisation) }
      it { is_expected.to be_falsy }
    end

    context 'with matching state' do
      let(:booking) { create(:booking, organisation: organisation, initial_state: :open_request) }
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end
end
