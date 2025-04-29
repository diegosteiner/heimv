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
#  occupancy_type     :integer          default("free"), not null
#  remarks            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#  occupiable_id      :bigint           not null
#

require 'rails_helper'

RSpec.describe Occupancy do
  # let(:occupancy)

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
end
