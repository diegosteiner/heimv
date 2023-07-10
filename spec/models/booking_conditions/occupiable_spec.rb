# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id                :bigint           not null, primary key
#  compare_attribute :string
#  compare_operator  :string
#  compare_value     :string
#  group             :string
#  must_condition    :boolean          default(TRUE)
#  qualifiable_type  :string
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :bigint
#  qualifiable_id    :bigint
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

RSpec.describe BookingConditions::Occupiable, type: :model do
  describe '#evaluate' do
    subject { booking_condition.evaluate(booking) }
    let(:compare_value) { '' }
    let(:booking_condition) { described_class.new(compare_value: compare_value, organisation: organisation) }
    let(:booking) { create(:booking, organisation: organisation) }
    let(:organisation) { create(:organisation) }
    let(:occupiable) { create(:home, organisation: organisation) }

    context 'without category' do
      it { is_expected.to be_falsy }
      it { expect(booking_condition).not_to be_valid }
    end

    context 'with occupiable by id' do
      let(:compare_value) { occupiable.id }
      let(:booking) { create(:booking, organisation: organisation, home: occupiable) }

      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end
end
