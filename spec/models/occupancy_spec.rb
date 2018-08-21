require 'rails_helper'

RSpec.describe Occupancy, type: :model do
  # let(:occupancy)

  describe '#nights' do
    subject { occupancy.nights }

    context '0 nights' do
      let(:occupancy) { build(:occupancy, begins_at: '2018-08-21 11:00', ends_at: '2018-08-21 23:00') }
      it { is_expected.to be 0 }
    end

    context '1 night' do
      let(:occupancy) { build(:occupancy, begins_at: '2018-08-21 22:00', ends_at: '2018-08-22 11:00') }
      it { is_expected.to be 1 }
    end

    context '2 nights' do
      let(:occupancy) { build(:occupancy, begins_at: '2018-08-21 11:00', ends_at: '2018-08-23 23:00') }
      it { is_expected.to be 2 }
    end
  end
end
